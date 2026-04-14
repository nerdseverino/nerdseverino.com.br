---
title: "Kiro + AWS: Gerenciando Infraestrutura por Conversa"
description: |
  Gerenciar infraestrutura AWS pelo terminal é o dia a dia de qualquer SRE. Mas entre lembrar a sintaxe exata do aws cli, montar filtros JSON, interpretar saídas gigantes e alternar entre dezenas de contas, o trabalho operacional consome tempo demais. Integrar o Kiro CLI com AWS transformou a forma como eu opero — e vou mostrar como.

  🔗 https://nerdseverino.com.br/blog/kiro-aws-gerenciando-infraestrutura-por-conversa/
date: 2026-04-06T11:20:00-03:00
categories:
  - DevOps
  - AWS
tags:
  - kiro
  - aws
  - cli
  - ia
  - sre
  - automação
keywords:
  - kiro cli aws
  - aws-vault kiro
  - cloudwatch kiro
  - cost explorer ia
  - gerenciar aws terminal
  - sre aws
autoThumbnailImage: false
thumbnailImagePosition: top
---

Gerenciar infraestrutura AWS pelo terminal é o dia a dia de qualquer SRE. Mas entre lembrar a sintaxe exata do `aws cli`, montar filtros JSON, interpretar saídas gigantes e alternar entre dezenas de contas, o trabalho operacional consome tempo demais. Integrar o Kiro CLI com AWS transformou a forma como eu opero — e vou mostrar como.

<!--more-->

## O problema: muitas contas, muitos comandos

Se você gerencia múltiplas contas AWS — e como SRE, provavelmente gerencia — sabe que o fluxo é repetitivo:

1. Lembrar o nome do profile da conta
2. `aws-vault exec <conta>`
3. Montar o comando AWS CLI com os filtros certos
4. Interpretar a saída JSON
5. Repetir para a próxima conta

Multiplique isso por 20, 50, 80 contas e o dia acaba antes de você fazer algo produtivo.

## aws-vault + Kiro: acesso seguro por conversa

O primeiro passo é ensinar o Kiro a usar `aws-vault`. No steering file:

```markdown
# Acesso AWS
- Sempre usar aws-vault para acessar contas AWS
- Nunca usar credenciais diretas ou access keys em texto puro
- Perguntar o nome da conta antes de executar
- Verificar se o profile existe no ~/.aws/config
- Sugerir nomes parecidos em caso de erro
```

Com isso configurado, a interação fica natural:

```
Eu: "verifica as instâncias EC2 na conta cliente-prod"

Kiro: [verifica ~/.aws/config, encontra o profile]
      [executa: aws-vault exec cliente-prod -- aws ec2 describe-instances]
      [formata a saída em tabela legível]

      Encontrei 12 instâncias:
      | Nome          | ID                  | Tipo      | Estado  |
      |---------------|---------------------|-----------|---------|
      | web-server-01 | i-0abc123def456789  | t3.medium | running |
      | api-server-01 | i-0def456abc789012  | m5.large  | running |
      ...
```

O Kiro faz o trabalho chato: montar o comando, executar com as credenciais certas e formatar a saída. Eu foco na decisão.

## Análise de custos sem sair do terminal

Uma das integrações mais úteis é com o Cost Explorer. Em vez de abrir o console, navegar até Billing, configurar filtros e esperar carregar:

```
Eu: "quanto gastamos na conta cliente-prod no último mês?"

Kiro: [usa get_cost_and_usage com as datas corretas]

      Custo total março/2026: $4,287.32

      Top 5 serviços:
      | Serviço                    | Custo     | % Total |
      |----------------------------|-----------|---------|
      | EC2 - Compute              | $2,103.45 | 49.1%   |
      | RDS                        | $891.20   | 20.8%   |
      | S3                         | $412.67   | 9.6%    |
      | NAT Gateway                | $387.90   | 9.0%    |
      | CloudWatch                 | $198.33   | 4.6%    |
```

E a conversa continua naturalmente:

```
Eu: "compara com fevereiro"

Kiro: [usa get_cost_and_usage_comparisons]

      Variação fev → mar: +$623.45 (+17%)
      
      Maiores aumentos:
      - EC2: +$412.00 (+24%) ← novas instâncias lançadas em 15/03
      - NAT Gateway: +$156.00 (+67%) ← tráfego cross-AZ aumentou
```

Em 30 segundos tenho uma análise que levaria 10 minutos no console. E posso continuar perguntando: "o que causou o aumento no NAT Gateway?", "quais instâncias foram lançadas em março?", "tem instância ociosa?".

## CloudWatch: métricas e alarmes por conversa

Monitoramento é outra área onde a conversa acelera o trabalho:

```
Eu: "mostra o CPU das instâncias da conta cliente-prod nas últimas 6 horas"

Kiro: [usa get_metric_data com namespace AWS/EC2]
      [agrupa por InstanceId]

      CPU Utilization (últimas 6h):
      | Instância     | Média | Máx   | Atual |
      |---------------|-------|-------|-------|
      | web-server-01 | 23%   | 67%   | 18%   |
      | api-server-01 | 78%   | 95%   | 82%   |  ← atenção
      | worker-01     | 12%   | 34%   | 8%    |

      ⚠️ api-server-01 está consistentemente acima de 70%.
      Recomendação: avaliar rightsizing para m5.xlarge ou investigar carga.
```

O Kiro não só busca os dados — ele interpreta. Identifica anomalias, sugere ações e conecta com o contexto que já conhece (se o memory.md menciona um incidente nessa conta, ele correlaciona).

## Alarmes ativos: visão geral rápida

```
Eu: "tem algum alarme disparando?"

Kiro: [usa get_active_alarms]

      2 alarmes em ALARM:
      
      1. rds-cpu-high (há 45 min)
         RDS CPUUtilization > 80% por 3 períodos
         Instância: db-prod-01
      
      2. disk-usage-critical (há 2h)
         DiskSpaceUtilization > 90%
         Instância: worker-03
```

Sem abrir console, sem navegar entre regiões, sem filtrar manualmente.

## Investigação de logs

Quando preciso investigar um problema, a integração com CloudWatch Logs Insights é poderosa:

```
Eu: "busca erros no log do lambda auth-service na última hora"

Kiro: [descobre o log group]
      [monta query Logs Insights]
      [executa e formata]

      23 erros encontrados na última hora:
      
      Top padrões:
      | Erro                              | Contagem |
      |-----------------------------------|----------|
      | TokenExpiredError                  | 15       |
      | ConnectionTimeoutError (DynamoDB)  | 6        |
      | ValidationError (missing field)    | 2        |
      
      Pico de erros: 10:15-10:25 (coincide com deploy às 10:14)
```

A query que o Kiro monta seria algo como:

```
filter @message like /(?i)(error|exception|fail|timeout)/
| stats count(*) as cnt by @message
| sort cnt desc
| limit 20
```

Eu poderia montar isso manualmente? Sim. Mas o Kiro faz em 5 segundos e já correlaciona com eventos recentes.

## Multi-conta: o superpoder

O cenário mais comum no meu dia a dia é verificar algo em várias contas. Sem o Kiro:

```bash
# Repetir para cada conta...
aws-vault exec conta1 -- aws ec2 describe-instances --query '...'
aws-vault exec conta2 -- aws ec2 describe-instances --query '...'
aws-vault exec conta3 -- aws ec2 describe-instances --query '...'
# ... mais 17 contas
```

Com o Kiro:

```
Eu: "verifica se tem Security Group com 0.0.0.0/0 na porta 22 
     nas contas cliente-prod, cliente-staging e cliente-dev"

Kiro: [executa em sequência com aws-vault]

      Resultados:
      
      cliente-prod: ✅ Nenhum SG exposto
      cliente-staging: ⚠️ 1 SG encontrado
        - sg-0abc123 "temp-debug" porta 22 aberta para 0.0.0.0/0
          Criado em: 2026-03-15 (16 dias atrás)
      cliente-dev: ⚠️ 2 SGs encontrados
        - sg-0def456 "dev-access" porta 22
        - sg-0ghi789 "test-ssh" porta 22
```

Uma pergunta, três contas auditadas. Isso escala para qualquer número de contas.

## O steering que faz tudo funcionar

Para a integração AWS funcionar bem, o steering precisa de algumas regras:

```markdown
# AWS
- Sempre usar aws-vault para acesso
- Verificar se o profile existe antes de executar
- Para custos: usar UnblendedCost como métrica padrão
- Para EC2: sempre incluir Name tag na saída
- Para Security Groups: alertar sobre 0.0.0.0/0 em portas sensíveis
- Para logs: limitar queries a 50 resultados para não estourar contexto
```

E no mapa de skills:

```markdown
| aws-cost-optimizer | Análise de custos, billing, rightsizing, FinOps |
| security-auditor | Auditoria IAM, Security Groups, compliance |
| log-analyzer | Análise de logs CloudWatch, syslog, Docker |
```

## O que não funciona (ainda)

Nem tudo é perfeito:

- **Operações destrutivas**: O Kiro pode executar `terminate-instances` se você pedir. Tenha cuidado e configure guardrails no steering ("nunca terminar instâncias sem confirmação explícita")
- **Sessões longas com muitas contas**: O contexto cresce rápido quando você consulta várias contas. Use a skill `context-optimization` para sessões pesadas
- **Latência**: Cada comando AWS passa por aws-vault + API. Em sequência, pode demorar. Para auditorias grandes, scripts dedicados ainda são mais eficientes
- **Dados sensíveis**: A saída dos comandos AWS pode conter IPs, ARNs e dados de clientes. Cuidado ao compartilhar sessões

## Quando usar Kiro vs script

| Cenário | Kiro | Script |
|---------|------|--------|
| Investigação ad-hoc | ✅ | ❌ |
| Auditoria rápida (3-5 contas) | ✅ | ❌ |
| Análise de custos pontual | ✅ | ❌ |
| Troubleshooting com contexto | ✅ | ❌ |
| Auditoria completa (50+ contas) | ❌ | ✅ |
| Automação recorrente | ❌ | ✅ |
| Pipeline CI/CD | ❌ | ✅ |

O Kiro brilha na investigação interativa — quando você não sabe exatamente o que está procurando e precisa ir refinando. Para tarefas repetitivas e previsíveis, scripts continuam sendo a melhor opção.

---

*Gerenciar AWS por conversa não substitui a automação — complementa. O Kiro cuida do trabalho exploratório e ad-hoc, liberando você para investir tempo em automação do que realmente precisa ser automatizado. Se você passa mais de uma hora por dia no console AWS, vale experimentar.*
