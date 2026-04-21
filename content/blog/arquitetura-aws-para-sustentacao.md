---
title: "Arquitetura AWS para Sustentação: Multi-Account, VPC e Alta Disponibilidade"
date: 2026-05-13T08:00:00-03:00
draft: true
description: |
  Você herdou uma conta AWS com 200 recursos sem tag, VPCs com CIDR conflitante e tudo rodando em uma única AZ.

  Sustentação começa com fundação sólida:

  ⚡ Multi-account: separar prod/dev/staging/shared
  ⚡ VPC design: CIDRs planejados, subnets públicas/privadas
  ⚡ Multi-AZ: o mínimo para não perder sono
  ⚡ Naming e tagging: encontrar recursos sem precisar de arqueologia

  Arquitetura boa é a que facilita a operação no dia a dia, não a que fica bonita no diagrama.

  Qual o maior problema de arquitetura que você já herdou?

  🔗 https://nerdseverino.com.br/blog/arquitetura-aws-para-sustentacao/

  #AWS #Arquitetura #SRE #MultiAccount #VPC #DevOps
categories:
  - SRE
  - AWS
tags:
  - aws
  - arquitetura
  - vpc
  - multi-account
  - sustentação
keywords:
  - arquitetura aws
  - multi account aws
  - vpc design
  - alta disponibilidade
autoThumbnailImage: false
thumbnailImagePosition: top
---

Arquitetura AWS bonita no diagrama mas impossível de operar é o cenário mais comum que encontro em clientes. Sustentação começa com fundação: contas organizadas, redes planejadas e recursos identificáveis.

<!--more-->

## Multi-Account: por que separar

Uma única conta AWS para tudo é o caminho mais rápido para o caos:

- Dev derruba prod por acidente
- Fatura impossível de atribuir
- Blast radius de incidentes é total
- Compliance vira pesadelo

### Estrutura mínima recomendada

| Conta | Propósito |
|-------|-----------|
| Management | Billing, Organizations, SCPs |
| Shared Services | DNS, VPN, monitoramento, CI/CD |
| Production | Workloads de produção |
| Staging | Espelho de prod para validação |
| Development | Ambientes de desenvolvimento |
| Security/Audit | CloudTrail, Config, GuardDuty |

### AWS Organizations e SCPs

SCPs (Service Control Policies) são guardrails que previnem erros:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": ["ec2:RunInstances"],
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": ["us-east-1", "sa-east-1"]
        }
      }
    }
  ]
}
```

Esse SCP impede criar recursos fora das regiões permitidas. Simples e efetivo.

## VPC Design

### CIDR Planning

O erro mais comum: usar o mesmo CIDR em todas as VPCs. Quando precisar de peering ou VPN, os ranges conflitam.

| Conta | VPC CIDR | Subnets Públicas | Subnets Privadas |
|-------|----------|-----------------|-----------------|
| Shared | 10.0.0.0/16 | 10.0.1.0/24, 10.0.2.0/24 | 10.0.10.0/24, 10.0.20.0/24 |
| Prod | 10.1.0.0/16 | 10.1.1.0/24, 10.1.2.0/24 | 10.1.10.0/24, 10.1.20.0/24 |
| Staging | 10.2.0.0/16 | 10.2.1.0/24, 10.2.2.0/24 | 10.2.10.0/24, 10.2.20.0/24 |
| Dev | 10.3.0.0/16 | 10.3.1.0/24, 10.3.2.0/24 | 10.3.10.0/24, 10.3.20.0/24 |

### Subnets: pública vs privada

- **Pública**: ALB, NAT Gateway, bastion (se ainda usar)
- **Privada**: EC2, RDS, ECS, Lambda (tudo que não precisa de IP público)

Regra: se não precisa receber tráfego da internet, vai na subnet privada.

### Multi-AZ

O mínimo para produção:

- ALB em 2+ AZs
- RDS Multi-AZ (failover automático)
- ECS/EC2 distribuídos em 2+ AZs
- NAT Gateway por AZ (evitar single point of failure)

## Naming e Tagging

### Convenção de nomes

```
{ambiente}-{serviço}-{componente}-{região}

Exemplos:
prod-api-alb-use1
staging-worker-ec2-use1
shared-vpn-tgw-use1
```

### Tags obrigatórias

| Tag | Exemplo |
|-----|---------|
| Name | prod-api-alb |
| Environment | production |
| Team | platform |
| Service | api |
| ManagedBy | terraform |
| CostCenter | projeto-x |

### Enforcement

```bash
# SCP que nega criação de EC2 sem tags obrigatórias
# Ou AWS Config rule: required-tags
```

## IAM: princípio do menor privilégio

- Roles ao invés de users para aplicações
- Roles cross-account para acesso entre contas
- MFA obrigatório para console
- Access keys com rotação (ou melhor: não usar)

```bash
# Exemplo: role para EC2 acessar S3 específico
# Não: s3:*
# Sim: s3:GetObject no bucket específico
```

## Checklist de sustentação

- [ ] Contas separadas por ambiente
- [ ] SCPs para guardrails básicos
- [ ] VPCs com CIDRs não conflitantes
- [ ] Subnets públicas e privadas
- [ ] Multi-AZ para produção
- [ ] Tagging obrigatório
- [ ] CloudTrail habilitado em todas as contas
- [ ] Billing alerts configurados
- [ ] Backup automático (RDS snapshots, EBS snapshots)
- [ ] Documentação de rede (diagrama atualizado)

---

*Arquitetura para sustentação não é sobre usar o serviço mais moderno. É sobre organização, previsibilidade e facilidade de operação. Se você consegue encontrar qualquer recurso em 30 segundos pelo nome ou tag, sua fundação está sólida.*
