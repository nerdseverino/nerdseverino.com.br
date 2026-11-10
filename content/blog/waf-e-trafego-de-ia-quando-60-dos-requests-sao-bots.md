---
title: "Metade do tráfego que você paga pra servir nem é humano"
cover:
  image: /images/uploads/waf-e-trafego-de-ia-quando-60-dos-requests-sao-bots.jpeg
  alt: "Metade do tráfego que você paga pra servir nem é humano"
date: 2026-11-10T07:47:34-03:00
description: |
  Você dimensionou a infra, ajustou o auto scaling, otimizou tudo. E metade do que você paga pra servir nem é gente.

  O que o tráfego de bot faz com a sua operação sem você ver:
  ❌ Infla o custo de infra servindo quem nunca vai comprar
  ❌ Distorce a latência p99 que você usa pra decidir escala
  ❌ Amplia a superfície de ataque com scraping e brute force
  ❌ Estoura capacity planning feito pra humano

  30 a 60% do tráfego web hoje é bot e agente de IA. Dimensionar ignorando isso é dimensionar no escuro.

  O AWS WAF Bot Control dá a visibilidade: separa humano de bot e deixa você decidir o que bloquear, limitar ou até monetizar.

  Você já mediu quanto do seu tráfego é bot, ou dimensiona no escuro?

  #AWS #WAF #Security #SRE
categories:
  - AWS
  - SRE
tags:
  - aws
  - waf
  - segurança
  - bots
  - ia
  - performance
keywords:
  - aws waf bot control
  - tráfego bots ia
  - rate limiting aws
  - cloudfront waf
  - bot detection
autoThumbnailImage: false
thumbnailImagePosition: top
---

Em 2026, entre 30% e 60% do tráfego que chega nos seus servidores não é humano. São crawlers de busca, scrapers de conteúdo, agentes de IA treinando modelos, e bots maliciosos tentando encontrar vulnerabilidades. Se você não sabe quanto do seu tráfego é bot, está tomando decisões de capacity planning, performance e segurança com dados errados.

<!--more-->

## O problema real

Quando metade do tráfego é bot, várias coisas quebram silenciosamente:

| Impacto | Consequência |
|---------|-------------|
| Custos inflados | Você paga por requests que não geram receita |
| Métricas distorcidas | Latência p99 inclui bots que acessam padrões diferentes |
| Capacity planning errado | Auto scaling dimensionado para tráfego que não é real |
| Rate limiting ineficaz | Limites pensados para humanos são facilmente atingidos por bots |
| SEO prejudicado | Crawlers agressivos podem derrubar o site durante indexação |

O primeiro passo é ter **visibilidade**. Sem saber quem está acessando, você não pode decidir o que fazer.

## AWS WAF Bot Control

O WAF Bot Control identifica e classifica bots automaticamente. O catálogo tem mais de 650 bots e agentes únicos identificados.

### Habilitando visibilidade (modo count)

Comece em modo **count** (não bloqueia, só registra):

```bash
# Adicionar Bot Control rule group ao WebACL (modo count)
aws wafv2 update-web-acl \
  --name "minha-webacl" \
  --scope REGIONAL \
  --id "webacl-id" \
  --default-action '{"Allow": {}}' \
  --rules '[{
    "Name": "AWS-AWSManagedRulesBotControlRuleSet",
    "Priority": 0,
    "OverrideAction": {"Count": {}},
    "Statement": {
      "ManagedRuleGroupStatement": {
        "VendorName": "AWS",
        "Name": "AWSManagedRulesBotControlRuleSet",
        "ManagedRuleGroupConfigs": [{"AWSManagedRulesBotControlRuleSetConfig": {"InspectionLevel": "COMMON"}}]
      }
    },
    "VisibilityConfig": {"SampledRequestsEnabled": true, "CloudWatchMetricsEnabled": true, "MetricName": "BotControl"}
  }]'
```

### Analisando o tráfego

Após 1-2 semanas em modo count, analise:

```bash
# Ver estatísticas de bots por categoria
aws wafv2 get-sampled-requests \
  --web-acl-arn "arn:aws:wafv2:us-east-1:ACCOUNT:regional/webacl/NAME/ID" \
  --rule-metric-name "BotControl" \
  --scope REGIONAL \
  --time-window StartTime=$(date -u -d '24 hours ago' +%s),EndTime=$(date -u +%s) \
  --max-items 500
```

### Classificação de bots

| Categoria | Exemplos | Ação recomendada |
|-----------|----------|-----------------|
| Verified (bons) | Googlebot, Bingbot | Permitir (necessários para SEO) |
| Unverified (suspeitos) | Scrapers genéricos | Rate limit |
| AI Agents | GPTBot, ClaudeBot, Bytespider | Decidir caso a caso |
| Maliciosos | Scanners, brute force | Bloquear |

## Separando métricas: humanos vs bots

Esse é o ponto que mais impacta SRE. Se 50% do tráfego é bot, suas métricas de latência estão erradas:

```bash
# Criar métrica customizada só para tráfego humano
# Usar label do WAF para filtrar
aws cloudwatch get-metric-data \
  --metric-data-queries '[
    {"Id": "human_latency", "MetricStat": {"Metric": {"Namespace": "AWS/ApplicationELB", "MetricName": "TargetResponseTime", "Dimensions": [{"Name": "LoadBalancer", "Value": "app/meu-alb/abc123"}]}, "Period": 300, "Stat": "p99"}}
  ]'
```

Na prática, a separação mais eficaz é via CloudFront + WAF labels nos logs:

1. WAF classifica o request (bot/humano)
2. CloudFront loga com o label
3. Athena filtra por label nas queries de performance
4. Dashboard mostra métricas separadas

## Rate limiting inteligente

Não bloqueie tudo. Limite por categoria:

```bash
# Rate limit: máximo 100 requests/5min para bots não verificados
aws wafv2 create-rule-group \
  --name "bot-rate-limit" \
  --scope REGIONAL \
  --capacity 50 \
  --rules '[{
    "Name": "rate-limit-unverified-bots",
    "Priority": 1,
    "Action": {"Block": {}},
    "Statement": {
      "RateBasedStatement": {
        "Limit": 100,
        "AggregateKeyType": "IP",
        "ScopeDownStatement": {
          "LabelMatchStatement": {
            "Scope": "LABEL",
            "Key": "awswaf:managed:aws:bot-control:bot:unverified"
          }
        }
      }
    },
    "VisibilityConfig": {"SampledRequestsEnabled": true, "CloudWatchMetricsEnabled": true, "MetricName": "BotRateLimit"}
  }]'
```

## Decisões sobre agentes de IA

Os crawlers de IA (GPTBot, ClaudeBot, Bytespider, etc.) são uma categoria nova. Opções:

| Estratégia | Quando usar |
|-----------|-------------|
| Permitir | Quer que seu conteúdo apareça em respostas de IA |
| Bloquear via robots.txt | Não quer treinar modelos com seu conteúdo |
| Rate limit | Permitir mas controlar volume |
| Monetizar (x402) | Cobrar por acesso (experimental) |

```text
# robots.txt para controlar crawlers de IA
User-agent: GPTBot
Disallow: /

User-agent: ClaudeBot
Disallow: /

User-agent: Bytespider
Disallow: /

# Permitir buscadores tradicionais
User-agent: Googlebot
Allow: /
```

## Impacto no capacity planning

Antes de dimensionar infraestrutura, saiba quanto do tráfego é real:

```text
Tráfego total: 10.000 req/min
Tráfego bot: 6.000 req/min (60%)
Tráfego humano: 4.000 req/min (40%)

Se bloquear bots agressivos: -3.000 req/min
Novo dimensionamento: 7.000 req/min (30% menos infra)
```

Isso pode significar reduzir instâncias, diminuir auto scaling max, e economizar 20-30% em compute.

## Checklist de implementação

1. Habilitar WAF Bot Control em modo **count** (1-2 semanas)
2. Analisar distribuição: quanto é bot vs humano?
3. Classificar bots: verificados, não verificados, IA, maliciosos
4. Definir política por categoria (permitir, limitar, bloquear)
5. Separar métricas de performance (humano vs bot)
6. Ajustar capacity planning com dados reais
7. Revisar robots.txt para crawlers de IA
8. Monitorar custos antes/depois (economia esperada: 15-30%)

---

*Se você gerencia infraestrutura web e nunca olhou quanto do seu tráfego é bot, faça isso esta semana. O resultado vai mudar como você dimensiona, monitora e protege seus serviços. Em 2026, ignorar tráfego de IA é como ignorar mobile em 2015 — vai te custar caro.*
