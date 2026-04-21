---
title: "Route53 Private Hosted Zones: DNS Local para Simplificar sua Conta AWS"
date: 2026-05-20T08:00:00-03:00
description: |
  Cansado de hardcodar IPs em configs, parameter groups e security groups?

  Route53 Private Hosted Zones resolvem isso com DNS interno:

  ⚡ db.prod.internal → aponta para o RDS
  ⚡ cache.prod.internal → aponta para o ElastiCache
  ⚡ api.prod.internal → aponta para o ALB interno

  Mudou o endpoint? Atualiza o DNS, não 15 configs espalhadas.

  Funciona só dentro da VPC, sem custo de resolução externa.

  Você ainda usa IPs hardcoded nas suas configs?

  🔗 https://nerdseverino.com.br/blog/route53-private-hosted-zones/

  #AWS #Route53 #DNS #SRE #Infraestrutura #DevOps
categories:
  - SRE
  - AWS
tags:
  - serie-sre-na-pratica
  - aws
  - route53
  - dns
  - vpc
  - infraestrutura
keywords:
  - route53 private hosted zone
  - dns interno aws
  - dns local vpc
autoThumbnailImage: false
thumbnailImagePosition: top
---

Toda conta AWS que opero tem o mesmo problema: IPs e endpoints hardcoded em dezenas de lugares. Parameter groups do RDS com IP do Redis, security groups referenciando IPs que mudam, configs de aplicação com endpoints que quebram quando o recurso é recriado. Route53 Private Hosted Zones resolvem isso de forma elegante.

<!--more-->

## O problema

Cenário típico:

```
# application.yml
database.host=10.1.20.45
cache.host=10.1.20.67
queue.host=sqs.us-east-1.amazonaws.com

# Quando o RDS é recriado, o IP muda
# Quando o ElastiCache faz failover, o endpoint muda
# Resultado: aplicação quebra, corrida para atualizar configs
```

## A solução: DNS interno

Uma Private Hosted Zone é uma zona DNS que só resolve dentro da VPC associada:

```
prod.internal
├── db.prod.internal      → endpoint do RDS
├── cache.prod.internal   → endpoint do ElastiCache
├── api.prod.internal     → ALB interno
├── queue.prod.internal   → endpoint do SQS VPC endpoint
└── bastion.prod.internal → IP do bastion host
```

### Criando a zona

```bash
# Criar Private Hosted Zone
aws route53 create-hosted-zone \
  --name prod.internal \
  --vpc VPCRegion=us-east-1,VPCId=vpc-abc123 \
  --caller-reference $(date +%s) \
  --hosted-zone-config PrivateZone=true
```

### Adicionando registros

```bash
# Apontar para RDS
aws route53 change-resource-record-sets \
  --hosted-zone-id Z1234567890 \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "db.prod.internal",
        "Type": "CNAME",
        "TTL": 60,
        "ResourceRecords": [{"Value": "mydb.abc123.us-east-1.rds.amazonaws.com"}]
      }
    }]
  }'
```

### Usando na aplicação

```yaml
# application.yml - nunca mais IP hardcoded
database:
  host: db.prod.internal
  port: 5432

cache:
  host: cache.prod.internal
  port: 6379
```

## Casos de uso práticos

### RDS com failover

Quando o RDS faz failover Multi-AZ, o endpoint DNS do RDS muda internamente. Com CNAME apontando para o endpoint do RDS, a resolução é transparente.

### ElastiCache

ElastiCache tem endpoints diferentes para primary e replicas. Um CNAME para `cache.prod.internal` apontando para o primary endpoint simplifica a config.

### ALB interno

Serviços que se comunicam internamente via ALB:

```
api.prod.internal    → ALB do serviço de API
auth.prod.internal   → ALB do serviço de autenticação
worker.prod.internal → ALB do serviço de processamento
```

### Ambientes múltiplos

```
db.prod.internal     → RDS de produção
db.staging.internal  → RDS de staging
db.dev.internal      → RDS de desenvolvimento
```

Mesma config na aplicação, DNS diferente por ambiente.

### Parameter Groups e configs centralizadas

Ao invés de colocar IPs em Parameter Store:

```bash
# Antes: SSM Parameter com IP que muda
/prod/database/host = 10.1.20.45

# Depois: DNS que nunca muda
/prod/database/host = db.prod.internal
```

## Associando múltiplas VPCs

Uma zona pode resolver em múltiplas VPCs (mesmo cross-account):

```bash
# Associar VPC adicional
aws route53 associate-vpc-with-hosted-zone \
  --hosted-zone-id Z1234567890 \
  --vpc VPCRegion=us-east-1,VPCId=vpc-def456
```

Útil para shared services: a zona `shared.internal` resolve em todas as VPCs de todas as contas.

## Custo

| Item | Custo |
|------|-------|
| Hosted Zone | $0.50/mês |
| Queries (primeiro 1B) | $0.40 por milhão |

Na prática, menos de $1/mês para a maioria dos ambientes.

## Checklist de implementação

1. Definir convenção de nomes (ex: `{serviço}.{ambiente}.internal`)
2. Criar Private Hosted Zone por ambiente
3. Criar CNAMEs para RDS, ElastiCache, ALBs internos
4. Atualizar configs das aplicações para usar DNS
5. Associar VPCs que precisam resolver
6. Documentar os registros (quem aponta para o quê)
7. TTL baixo (60s) para failovers rápidos

---

*Private Hosted Zones custam centavos e eliminam uma classe inteira de problemas operacionais. Se você ainda tem IPs hardcoded em configs, esse é o próximo passo mais simples para melhorar sua operação AWS.*
