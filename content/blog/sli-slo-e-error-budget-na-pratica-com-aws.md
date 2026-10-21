---
title: "Quem decide se o deploy sobe hoje: o chefe ou o error budget?"
cover:
  image: /images/uploads/sli-slo-e-error-budget-na-pratica-com-aws.jpeg
  alt: "Quem decide se o deploy sobe hoje: o chefe ou o error budget?"
date: 2026-10-21T17:40:00-03:00
description: |
  Sexta à noite, alguém quer subir um deploy "rapidinho". O serviço já está instável a semana toda. Quem decide se pode? Na maioria dos times, a resposta é "o chefe que gritar mais alto". Devia ser o Error Budget.

  Na prática com AWS:

  📊 SLI: medir latência p99 e error rate no ALB
  🎯 SLO: definir "99.9% das requests abaixo de 500ms"
  🔥 Error Budget: quando acabar, deploy congela automaticamente
  ⏰ Burn Rate: alarme que avisa antes do budget acabar

  Mostro como implementar tudo com CloudWatch, sem ferramentas extras.

  No seu time, quem ganha quando o chefe quer deployar e o sistema está instável?

  #SRE #AWS #Observabilidade #SLO
categories:
  - SRE
  - AWS
tags:
  - sre
  - slo
  - observabilidade
  - cloudwatch
  - confiabilidade
keywords:
  - sli slo error budget
  - sre aws
  - cloudwatch slo
  - burn rate alarme
  - confiabilidade aws
autoThumbnailImage: false
thumbnailImagePosition: top
---

Todo mundo fala de SLO em apresentações. Poucos implementam de verdade. A diferença entre um time que "tem SLO" e um time que usa SLO é simples: no segundo, o Error Budget decide se o deploy acontece ou não. Sem discussão, sem exceção.

<!--more-->

## Conceitos em 30 segundos

| Conceito | O que é | Exemplo |
|----------|---------|---------|
| SLI (Indicator) | A métrica que mede a experiência do usuário | Latência p99, error rate, disponibilidade |
| SLO (Objective) | O alvo aceitável para o SLI | "99.9% das requests com latência < 500ms" |
| Error Budget | Quanto pode falhar sem quebrar o SLO | 0.1% = 43 minutos/mês de indisponibilidade |
| Burn Rate | Velocidade com que o budget está sendo consumido | 2x = vai acabar na metade do mês |

## Escolhendo SLIs que importam

Não meça tudo. Meça o que o usuário sente:

| Tipo de serviço | SLIs recomendados |
|-----------------|-------------------|
| API/Web | Latência p99, error rate (5xx), disponibilidade |
| Processamento batch | Tempo de conclusão, taxa de falha |
| Pipeline de dados | Freshness (atraso), completude |
| Storage | Durabilidade, latência de acesso |

**Regra prática:** Se o usuário não percebe a degradação, não é um bom SLI.

## Implementando com CloudWatch na AWS

### Passo 1: Coletar SLIs do ALB

O Application Load Balancer já emite as métricas que precisamos:

```bash
# Latência p99 (últimas 24h, intervalos de 5min)
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --dimensions Name=LoadBalancer,Value=app/meu-alb/abc123 \
  --start-time $(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics p99 \
  --extended-statistics p99

# Error rate (5xx / total requests)
aws cloudwatch get-metric-data \
  --metric-data-queries '[
    {"Id": "errors", "MetricStat": {"Metric": {"Namespace": "AWS/ApplicationELB", "MetricName": "HTTPCode_Target_5XX_Count", "Dimensions": [{"Name": "LoadBalancer", "Value": "app/meu-alb/abc123"}]}, "Period": 300, "Stat": "Sum"}},
    {"Id": "total", "MetricStat": {"Metric": {"Namespace": "AWS/ApplicationELB", "MetricName": "RequestCount", "Dimensions": [{"Name": "LoadBalancer", "Value": "app/meu-alb/abc123"}]}, "Period": 300, "Stat": "Sum"}},
    {"Id": "error_rate", "Expression": "(errors/total)*100", "Label": "Error Rate %"}
  ]' \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S)
```

### Passo 2: Definir SLOs

Baseie-se na linha de base real, não em números bonitos:

```text
Se a latência p99 atual é 320ms → SLO: 500ms (margem de ~50%)
Se o error rate atual é 0.02% → SLO: 0.1% (margem de 5x)
Se a disponibilidade atual é 99.95% → SLO: 99.9%
```

**Erro comum:** Definir SLO de 99.99% quando o sistema entrega 99.9%. Isso significa que você já está violando o SLO antes de começar.

### Passo 3: Criar alarmes de SLO

```bash
# Alarme: latência p99 acima do SLO (500ms)
aws cloudwatch put-metric-alarm \
  --alarm-name "slo-latency-p99-breach" \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --dimensions Name=LoadBalancer,Value=app/meu-alb/abc123 \
  --statistic p99 \
  --period 300 \
  --evaluation-periods 3 \
  --threshold 0.5 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions arn:aws:sns:us-east-1:ACCOUNT:sre-alerts

# Alarme: error rate acima do SLO (0.1%)
aws cloudwatch put-metric-alarm \
  --alarm-name "slo-error-rate-breach" \
  --metric-name HTTPCode_Target_5XX_Count \
  --namespace AWS/ApplicationELB \
  --dimensions Name=LoadBalancer,Value=app/meu-alb/abc123 \
  --statistic Sum \
  --period 300 \
  --evaluation-periods 3 \
  --threshold 5 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions arn:aws:sns:us-east-1:ACCOUNT:sre-alerts
```

### Passo 4: Burn Rate (o alarme que avisa antes de quebrar)

O alarme de SLO avisa quando já quebrou. O burn rate avisa quando **vai** quebrar:

| Burn Rate | Significado | Ação |
|-----------|-------------|------|
| 1x | Consumindo budget no ritmo normal | OK |
| 2x | Vai acabar na metade do mês | Investigar |
| 10x | Vai acabar em 3 dias | Parar deploys |
| 100x | Vai acabar em horas | Incidente |

```bash
# Alarme de burn rate rápido (10x em 5 minutos)
# Se error rate > 10x o budget em janela curta = incidente
aws cloudwatch put-metric-alarm \
  --alarm-name "slo-burnrate-fast" \
  --namespace AWS/ApplicationELB \
  --metric-name HTTPCode_Target_5XX_Count \
  --dimensions Name=LoadBalancer,Value=app/meu-alb/abc123 \
  --statistic Sum \
  --period 60 \
  --evaluation-periods 5 \
  --threshold 50 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions arn:aws:sns:us-east-1:ACCOUNT:sre-critical
```

## Error Budget na prática

Com SLO de 99.9% de disponibilidade em um mês de 30 dias:

```text
Error Budget = (1 - 0.999) × 30 dias × 24h × 60min = 43.2 minutos

Se já consumiu 30 minutos → restam 13 minutos
Se burn rate está em 5x → vai acabar em 2.6 dias
```

**Quando o budget acaba:**
1. Deploy congela (exceto hotfixes de confiabilidade)
2. Time foca em reduzir error rate
3. Só libera deploy quando budget recuperar

Isso não é burocracia. É o mecanismo que impede que features novas degradem o serviço.

## Dashboard mínimo

Um dashboard de SLO precisa responder 3 perguntas em 10 segundos:

1. **Estamos dentro do SLO?** (verde/vermelho)
2. **Quanto budget resta?** (percentual)
3. **Qual a tendência?** (melhorando/piorando)

```json
{
  "widgets": [
    {"type": "metric", "properties": {"title": "Latência p99 vs SLO (500ms)", "annotations": {"horizontal": [{"value": 0.5, "label": "SLO"}]}}},
    {"type": "metric", "properties": {"title": "Error Rate vs SLO (0.1%)", "annotations": {"horizontal": [{"value": 0.1, "label": "SLO"}]}}},
    {"type": "metric", "properties": {"title": "Error Budget Restante (%)"}}
  ]
}
```

## Checklist para começar

1. Escolha 2-3 SLIs (latência p99, error rate, disponibilidade)
2. Meça a linha de base por 2 semanas
3. Defina SLOs com margem realista
4. Crie alarmes de SLO breach
5. Crie alarmes de burn rate (rápido e lento)
6. Monte dashboard com as 3 perguntas
7. Combine com o time: "quando budget acabar, deploy para"

---

*SLO sem consequência é só um número. A mágica acontece quando o Error Budget tem poder real sobre o processo de deploy. Comece pequeno: um serviço, um SLO, um alarme. Depois expanda. Em 3 meses você não vai conseguir tomar decisões sem olhar essas métricas primeiro.*
