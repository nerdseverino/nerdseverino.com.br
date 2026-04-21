---
title: "FinOps para SREs: Controlando Custos AWS sem Perder Performance"
date: 2026-05-06T08:00:00-03:00
description: |
  A fatura AWS chegou 40% maior que o mês passado. Alguém sabe por quê?

  Se ninguém sabe, você tem um problema de FinOps.

  Quick wins que aplicamos em clientes reais:

  ⚡ Scheduling não-prod: desligar à noite = 70% economia
  ⚡ Rightsizing top 20%: instâncias rodando a 15% de CPU
  ⚡ gp2 → gp3: mesma performance, 20% mais barato
  ⚡ Savings Plans: só depois de 3-4 meses de dados reais

  FinOps não é cortar custos. É gastar com consciência.

  Qual foi a maior surpresa que você já teve numa fatura AWS?

  🔗 https://nerdseverino.com.br/blog/finops-para-sres/

  #FinOps #AWS #SRE #CloudCost #DevOps #Otimização
coverImage: /images/uploads/cover-finops.png
categories:
  - SRE
  - AWS
tags:
  - serie-sre-na-pratica
  - finops
  - aws
  - custos
  - otimização
  - sre
keywords:
  - finops aws
  - custos aws
  - rightsizing
  - savings plans
  - sre custos
coverImage: /images/uploads/cover-finops.png
autoThumbnailImage: false
coverImage: /images/uploads/cover-finops.png
thumbnailImagePosition: top
---

A fatura AWS é o relatório de performance que ninguém lê. Até o dia que chega 40% maior e todo mundo quer saber o que aconteceu. FinOps para SREs não é sobre cortar custos. É sobre gastar com consciência e ter visibilidade do que cada real está comprando.

<!--more-->

## O ciclo FinOps

FinOps funciona em três fases contínuas:

| Fase | Objetivo | Ações |
|------|----------|-------|
| **Inform** | Visibilidade | Tagging, atribuição de custos, dashboards |
| **Optimize** | Reduzir desperdício | Rightsizing, scheduling, Spot, commitments |
| **Operate** | Cultura | Budget alerts, sprints de otimização, ownership |

A maioria dos times pula direto para Optimize sem ter Inform. Resultado: otimizam às cegas.

## Passo zero: Tagging

Sem tags, você não sabe quem gasta o quê. Tags obrigatórias:

| Tag | Exemplo | Por que |
|-----|---------|---------|
| team | platform, backend | Quem é responsável |
| environment | prod, staging, dev | Onde desligar à noite |
| service | api, worker, db | O que consome |
| cost-center | projeto-x | Chargeback/showback |

Meta: menos de 5% do spend sem tag. Use SCPs no AWS Organizations para forçar tagging na criação de recursos.

## Quick wins (ordem de prioridade)

### 1. Scheduling de ambientes não-prod

O quick win com maior retorno. Ambientes de dev/staging não precisam rodar 24/7:

```bash
# Desligar dev às 20h, ligar às 8h (seg-sex)
# Economia: ~70% do custo dessas instâncias

# Via AWS Instance Scheduler ou simples cron com Lambda
# Tag: Schedule = office-hours
```

### 2. Rightsizing

A maioria das instâncias EC2 roda com CPU abaixo de 20%. Verifique:

```bash
# CloudWatch: CPUUtilization média dos últimos 14 dias
# Se < 20% consistentemente, pode reduzir o tipo

# Exemplo: m5.xlarge (4 vCPU, 16 GB) rodando a 10% CPU
# Candidato: m5.large (2 vCPU, 8 GB) = 50% mais barato
```

Use o AWS Compute Optimizer para recomendações automáticas. Comece pelos top 20% mais caros.

### 3. EBS: gp2 para gp3

Migração sem downtime, mesma performance base, 20% mais barato:

```bash
# Listar volumes gp2
aws ec2 describe-volumes \
  --filters "Name=volume-type,Values=gp2" \
  --query 'Volumes[].{ID:VolumeId,Size:Size,State:State}'

# Migrar (sem downtime)
aws ec2 modify-volume --volume-id vol-xxx --volume-type gp3
```

### 4. Snapshots e AMIs antigas

Snapshots acumulam silenciosamente:

```bash
# Snapshots com mais de 90 dias
aws ec2 describe-snapshots --owner-ids self \
  --query 'Snapshots[?StartTime<`2026-01-01`].{ID:SnapshotId,Size:VolumeSize,Date:StartTime}'
```

### 5. NAT Gateway

NAT Gateway cobra por GB processado. Alternativas:

- VPC Endpoints para S3 e DynamoDB (grátis para Gateway endpoints)
- NAT Instance para ambientes com pouco tráfego
- Revisar tráfego cross-AZ desnecessário

### 6. Savings Plans e Reserved Instances

Só compre depois de 3-4 meses de dados reais. Mix alvo:

| Tipo | % do spend | Quando |
|------|-----------|--------|
| Savings Plans | 50-70% | Workloads estáveis |
| Spot | 20-30% | Batch, CI/CD, tolerante a falha |
| On-Demand | 10-20% | Picos, novos serviços |

## S3: Lifecycle Policies

Dados que ninguém acessa custam o mesmo que dados ativos:

| Classe | Custo/GB/mês | Quando usar |
|--------|-------------|-------------|
| Standard | $0.023 | Acesso frequente |
| Standard-IA | $0.0125 | Acesso mensal |
| Glacier Instant | $0.004 | Acesso trimestral |
| Glacier Deep Archive | $0.00099 | Compliance, raramente acessado |

```json
{
  "Rules": [{
    "Status": "Enabled",
    "Transitions": [
      {"Days": 30, "StorageClass": "STANDARD_IA"},
      {"Days": 90, "StorageClass": "GLACIER"},
      {"Days": 365, "StorageClass": "DEEP_ARCHIVE"}
    ]
  }]
}
```

## Monitoramento de custos

### Budget Alerts

```bash
# Criar alerta quando atingir 80% do budget
aws budgets create-budget \
  --account-id 123456789012 \
  --budget file://budget.json \
  --notifications-with-subscribers file://notifications.json
```

### Cost Explorer via CLI

```bash
# Custo do mês atual por serviço
aws ce get-cost-and-usage \
  --time-period Start=2026-04-01,End=2026-04-30 \
  --granularity MONTHLY \
  --metrics UnblendedCost \
  --group-by Type=DIMENSION,Key=SERVICE
```

## Cultura FinOps

Ferramentas sem cultura não funcionam. Práticas que fazem diferença:

1. **Showback antes de chargeback**: Mostre os custos por time sem punir. Visibilidade gera consciência.
2. **Budget alerts no Slack/Telegram**: 80% do budget = notificação automática.
3. **Sprints de otimização quinzenais**: Top 3 desperdícios por time, ações concretas.
4. **"You build it, you pay for it"**: Quem cria o recurso é responsável pelo custo.

## Checklist mensal

- [ ] Revisar top 10 serviços por custo
- [ ] Verificar recursos sem tag
- [ ] Checar instâncias com CPU < 20%
- [ ] Revisar snapshots e AMIs antigas
- [ ] Verificar Savings Plans utilization
- [ ] Comparar custo MoM (mês a mês)

---

*FinOps não é projeto com início e fim. É um ciclo contínuo de visibilidade, otimização e cultura. Comece pelo tagging, aplique os quick wins, e construa o hábito de olhar custos com a mesma atenção que olha métricas de performance.*
