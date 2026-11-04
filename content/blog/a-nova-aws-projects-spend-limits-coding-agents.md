---
title: "A AWS enterrou o onboarding que te fez sofrer no primeiro dia"
cover:
  image: /images/uploads/a-nova-aws-projects-spend-limits-coding-agents.jpeg
  alt: "A AWS enterrou o onboarding que te fez sofrer no primeiro dia"
date: 2026-11-04T17:03:00-03:00
description: |
  Lembra do seu primeiro dia na AWS? Cartão de crédito, IAM incompreensível, uma VPC pra montar antes de subir um "hello world". A AWS resolveu enterrar isso.

  O novo onboarding inverte a lógica tradicional:

  🚪 Login com Google/GitHub/Apple, sem cartão de crédito
  💰 US$ 100 em créditos grátis
  📦 Conceito de "Project" (conta + sharing, sem IAM manual)
  🤖 Integração nativa com coding agent (gera CLAUDE.md)
  🛑 Spend limit que PAUSA o projeto ao atingir o teto

  Para quem já tem anos de AWS, isso levanta uma pergunta: a nuvem está ficando mais simples ou escondendo complexidade?

  Conta aí: como foi seu primeiro dia sofrido na AWS?

  #AWS #Cloud #DevOps #SRE
categories:
  - AWS
  - DevOps
tags:
  - aws
  - cloud
  - finops
  - ia
  - onboarding
keywords:
  - aws projects
  - aws spend limit
  - aws coding agent
  - aws getting started 2026
  - aws onboarding
autoThumbnailImage: false
thumbnailImagePosition: top
---

Em setembro de 2026 a AWS anunciou uma reformulação completa da experiência de getting started. Para quem começou na AWS há anos lutando com IAM, VPCs e cartões de crédito, a mudança parece de outro planeta. Mas por trás da simplificação tem decisões de arquitetura que valem entender.

<!--more-->

## A inversão da lógica

O modelo clássico da AWS sempre foi: configure antes de construir. Crie a conta, configure billing, aprenda IAM, monte uma VPC, só então faça deploy. A nova experiência inverte isso: defaults sensatos primeiro, configuração conforme a necessidade.

A proposta é clara: atender builders que trabalham no ritmo da IA, com coding agents fazendo deploy direto do terminal.

## O que mudou no cadastro

| Antes | Agora |
|-------|-------|
| Cartão de crédito obrigatório | Sem cartão para a maioria dos novos clientes |
| Conta root + IAM manual | Login via Google, GitHub, Apple |
| Free Tier com limites de serviço | US$ 100 em créditos |
| Configuração antes de usar | Constrói no primeiro projeto |

## O conceito de Project

Essa é a mudança estrutural mais interessante. Em vez de você gerenciar contas e IAM diretamente, o trabalho é organizado em **Projects**:

- Cada Project contém uma conta AWS (onde os recursos vivem)
- Configurações de compartilhamento com o time embutidas
- A AWS cria a estrutura e aplica controles de segurança automaticamente
- Criar outro projeto é um clique

Na prática, a AWS está escondendo o AWS Organizations e o IAM Identity Center atrás de uma abstração mais simples. Convite de colaborador agora é só por e-mail, sem criar usuários IAM.

## Spend limit: o fim do susto na fatura

Essa é a parte que mais me interessou como SRE. O modelo de billing tradicional da AWS é traiçoeiro: você só descobre o estrago quando a fatura chega. O novo spend limit muda isso:

- Limite mensal por projeto, começando em US$ 20/mês
- Você paga só o uso real até o teto
- Ao se aproximar do limite, recebe notificação
- **Ao atingir o limite, a AWS PAUSA o projeto** em vez de acumular cobrança
- Retoma quando você aumenta o limite

Isso é um divisor de águas para quem já tomou susto com fatura. O comportamento de "pausar em vez de cobrar" é o oposto do modelo tradicional pay-as-you-go, onde o céu era o limite (e o bolso também).

## Integração com coding agent

Depois do login, você recebe um prompt para colar no seu coding agent. O agente então:

1. Instala o AWS CLI e o Agent Toolkit for AWS
2. Faz login no ambiente
3. Cria um arquivo de contexto (CLAUDE.md) no projeto
4. Passa a fazer deploy de recursos seguindo best practices

No exemplo do anúncio, um prompt simples ("construir uma API que retorna um ID sequencial") gerou automaticamente uma função Lambda, uma tabela DynamoDB e uma API no API Gateway, com deploy completo.

## O que isso significa para quem já é da área

Como SRE, tenho sentimentos divididos:

**O lado bom:**
- Reduz a barreira de entrada drasticamente
- Spend limit resolve um problema real de controle de custos
- Permissões automáticas eliminam horas de troubleshooting de IAM

**O lado que exige atenção:**
- Abstração esconde complexidade, mas ela continua lá embaixo
- Quando o projeto cresce, você vai precisar entender IAM, VPC e Organizations de verdade
- "Defaults sensatos" nem sempre são os defaults certos para produção
- Dependência de coding agent para operar infra pode criar uma geração que não entende o que está rodando

## A real: para quem é isso?

Essa experiência é claramente para quem está começando ou para protótipos rápidos. Para workloads de produção sérios, você ainda vai precisar do controle fino que a AWS sempre ofereceu. A boa notícia é que a própria AWS diz que a amplitude e profundidade continuam disponíveis quando o projeto cresce, sem migração.

O risco é a mesma armadilha de sempre: facilitar a entrada é ótimo, desde que não crie uma geração de builders que sabe fazer deploy mas não sabe o que fazer quando quebra às 3 da manhã.

---

*A AWS está apostando que o futuro é builders + coding agents. Faz sentido. Mas o SRE em mim lembra que abstração não elimina complexidade, só adia o momento em que você precisa entendê-la. Para começar e prototipar, excelente. Para produção, continue estudando IAM.*
