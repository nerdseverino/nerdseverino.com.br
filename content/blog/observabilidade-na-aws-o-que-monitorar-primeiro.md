---
title: "Observabilidade na AWS: o que monitorar primeiro"
date: 2026-04-21T01:15:00-03:00
description: |
  Seu CloudWatch tem 200 alarmes e nenhum deles te acorda quando realmente importa?

  O problema não é falta de monitoramento. É excesso de ruído.

  Depois de operar dezenas de contas AWS, aprendi que observabilidade começa com 3 perguntas:

  ⚡ O serviço está respondendo? (disponibilidade)
  ⚡ Está respondendo rápido? (latência p99)
  ⚡ Está respondendo certo? (taxa de erro)

  Se você não consegue responder essas 3 em 10 segundos, seu monitoramento precisa de ajuste.

  O post completo cobre: métricas essenciais por serviço, alarmes que fazem sentido, dashboards úteis vs dashboards bonitos, e um checklist para começar hoje.

  Qual métrica você olha primeiro quando recebe um alerta?

  🔗 https://nerdseverino.com.br/blog/observabilidade-na-aws-o-que-monitorar-primeiro/

  #AWS #SRE #CloudWatch #Observabilidade #Monitoramento #DevOps
categories:
  - SRE
  - AWS
tags:
  - serie-sre-na-pratica
  - aws
  - cloudwatch
  - monitoramento
  - observabilidade
  - sre
  - alertas
keywords:
  - observabilidade aws
  - cloudwatch alarmes
  - monitoramento aws
  - sre aws
  - métricas cloudwatch
cover:
  image: "/images/uploads/cover-observabilidade-aws.jpg"
  alt: "Cover"
  relative: false
autoThumbnailImage: false
thumbnailImagePosition: top
---

Seu CloudWatch tem 200 alarmes e nenhum deles te acorda quando realmente importa? Você não está sozinho. A maioria dos ambientes AWS que encontro tem monitoramento demais e observabilidade de menos.

<!--more-->

## Monitoramento vs Observabilidade

Monitoramento é coletar métricas. Observabilidade é conseguir responder perguntas que você não previu.

Na prática:
- **Monitoramento**: "CPU está acima de 80%"
- **Observabilidade**: "Por que o checkout está lento para usuários do Nordeste às 14h?"

O CloudWatch faz os dois, mas a maioria dos times para no primeiro.

## As 3 perguntas que importam

Antes de criar qualquer alarme, dashboard ou log group, responda:

1. **O serviço está respondendo?** (disponibilidade)
2. **Está respondendo rápido?** (latência)
3. **Está respondendo certo?** (taxa de erro)

Se você consegue responder essas 3 em 10 segundos olhando um dashboard, seu monitoramento está no caminho certo. Se precisa abrir 5 telas e cruzar dados mentalmente, precisa simplificar.

## Métricas essenciais por serviço

### EC2

| Métrica | Alarme quando | Por que |
|---------|--------------|---------|
| StatusCheckFailed | > 0 por 2 min | Instância com problema de hardware/rede |
| CPUCreditBalance | < 20 (burstable) | t3/t4g vai ficar lenta |
| MemoryUtilization* | > 85% por 5 min | Precisa do CloudWatch Agent |
| DiskSpaceUtilization* | > 85% | Disco cheio = serviço para |

*Requer CloudWatch Agent instalado.

### RDS

| Métrica | Alarme quando | Por que |
|---------|--------------|---------|
| FreeStorageSpace | < 5 GB | Banco para quando disco enche |
| CPUUtilization | > 80% por 10 min | Queries pesadas ou instância subdimensionada |
| DatabaseConnections | > 80% do max | Connection leak ou pool mal configurado |
| FreeableMemory | < 500 MB | Banco começa a usar swap |
| ReplicaLag | > 30 seg | Réplica de leitura atrasada |

### ALB/NLB

| Métrica | Alarme quando | Por que |
|---------|--------------|---------|
| HTTPCode_ELB_5XX_Count | > 0 por 3 min | Load balancer retornando erro |
| TargetResponseTime (p99) | > threshold | Latência percebida pelo usuário |
| UnHealthyHostCount | > 0 | Target group com instâncias doentes |
| RequestCount | queda > 50% | Possível problema de DNS ou rede |

### ECS/Fargate

| Métrica | Alarme quando | Por que |
|---------|--------------|---------|
| CPUUtilization (service) | > 80% por 5 min | Precisa escalar |
| MemoryUtilization (service) | > 80% por 5 min | Risco de OOM kill |
| RunningTaskCount | < DesiredCount | Tasks morrendo |

### Lambda

| Métrica | Alarme quando | Por que |
|---------|--------------|---------|
| Errors | > 0 por 3 min | Função falhando |
| Duration (p99) | > 80% do timeout | Próximo de estourar timeout |
| Throttles | > 0 | Limite de concorrência atingido |
| ConcurrentExecutions | > 80% do limite | Precisa solicitar aumento |

## Alarmes que fazem sentido vs ruído

### O problema do alarme de CPU

"CPU acima de 80%" é o alarme mais comum e um dos menos úteis. Por que:

- CPU alta pode ser normal (batch processing, deploy, autoscaling)
- CPU baixa não significa que está tudo bem (pode estar travado em I/O)
- Não te diz o impacto no usuário

### Alarmes baseados em sintoma vs causa

| Tipo | Exemplo | Valor |
|------|---------|-------|
| **Sintoma** (preferir) | Taxa de erro 5xx > 1% | Impacto direto no usuário |
| **Sintoma** (preferir) | Latência p99 > 500ms | Usuário percebe lentidão |
| **Causa** (complementar) | CPU > 90% por 15 min | Ajuda no diagnóstico |
| **Causa** (complementar) | Disco > 90% | Prevenção |

Comece pelos sintomas. Adicione causas para ajudar no diagnóstico, não como alarme primário.

### Anatomia de um bom alarme

| Campo | Exemplo |
|-------|---------|
| Nome | prod-api-error-rate-high |
| Métrica | HTTPCode_Target_5XX_Count / RequestCount * 100 |
| Threshold | > 1% por 3 datapoints de 1 minuto |
| Ação | SNS → PagerDuty/Telegram |
| Runbook | link para procedimento de investigação |

Cada alarme deve ter:
- Nome descritivo (ambiente + serviço + problema)
- Threshold baseado em baseline real (não chute)
- Período que evita falsos positivos
- Ação clara (quem é notificado)
- Link para runbook (o que fazer quando disparar)

## Dashboards úteis vs dashboards bonitos

### Dashboard que ninguém usa

- 30 widgets mostrando tudo
- Métricas sem contexto
- Sem threshold visual
- Precisa de 5 minutos para entender

### Dashboard que salva no incidente

Três dashboards, cada um com propósito claro:

**1. Dashboard Operacional (SRE)**
- Disponibilidade (%) com linha de threshold
- Latência p99 com linha de threshold
- Taxa de erro com linha de threshold
- Tasks/instâncias running vs desired
- Alarmes ativos

**2. Dashboard de Infraestrutura**
- CPU, memória, disco por instância/serviço
- Conexões de banco
- Fila de mensagens (SQS depth)
- Network I/O

**3. Dashboard Executivo**
- Status: verde/amarelo/vermelho
- Uptime do mês
- Incidentes abertos
- Resposta em 10 segundos: "está tudo bem?"

## CloudWatch Logs: o mínimo necessário

```bash
# Logs que todo ambiente deveria ter
/aws/ec2/syslog              # Sistema operacional
/aws/rds/error                # Erros do banco
/aws/ecs/container-logs       # Aplicação
/aws/lambda/function-name     # Funções serverless
/aws/alb/access-logs          # Requisições HTTP (S3)
```

### Log Insights: queries que uso toda semana

```sql
-- Top 10 erros na última hora
filter @message like /(?i)(error|exception|fail)/
| stats count(*) as total by @message
| sort total desc
| limit 10

-- Latência por endpoint
filter @type = "REPORT"
| stats avg(@duration) as avg_ms,
        pct(@duration, 99) as p99_ms
  by bin(5m)

-- Requisições 5xx no ALB
filter elb_status_code >= 500
| stats count(*) as errors by target_status_code, request_url
| sort errors desc
| limit 20
```

## Checklist: comece hoje

Se você está partindo do zero ou quer reorganizar:

1. **Instale o CloudWatch Agent** nas EC2 (memória e disco não vêm por padrão)
2. **Crie 3 alarmes por serviço**: disponibilidade, latência, erro
3. **Configure SNS** para notificações (Telegram, Slack, PagerDuty)
4. **Crie 1 dashboard operacional** com as 3 métricas principais
5. **Habilite Log Insights** nos log groups mais importantes
6. **Documente thresholds** (por que 80%? baseado em que baseline?)
7. **Revise alarmes mensalmente** (remova os que ninguém olha)

## O que não monitorar

Tão importante quanto saber o que monitorar é saber o que ignorar:

- Métricas que nunca geraram ação
- Alarmes que são sempre silenciados
- Dashboards que ninguém abre há 30 dias
- Logs sem retention policy (custam dinheiro eternamente)

Cada métrica coletada, cada alarme configurado e cada log armazenado tem custo. Se não gera ação, é desperdício.

---

*Observabilidade não é ter mais dados. É ter os dados certos, no momento certo, com contexto suficiente para agir. Comece pelas 3 perguntas, adicione complexidade conforme a necessidade, e revise regularmente. O melhor monitoramento é aquele que te acorda apenas quando realmente precisa.*
