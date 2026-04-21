---
title: "On-Call sem Burnout: Organizando Plantão em Times Pequenos"
date: 2026-06-05T08:00:00-03:00
description: |
  On-call não precisa ser sinônimo de noites sem dormir e ansiedade constante.

  Práticas que fazem diferença em times pequenos:

  ⚡ Rotação justa (mínimo 1 semana entre plantões)
  ⚡ Runbooks para os top 10 alertas (N1 resolve 80%)
  ⚡ Escalação clara (quando escalar, para quem)
  ⚡ Compensação real (folga, não só "obrigado")
  ⚡ Reduzir alertas falsos (cada falso positivo é dívida de confiança)

  On-call sustentável é on-call que o time não teme.

  Como funciona o on-call no seu time?

  🔗 https://nerdseverino.com.br/blog/on-call-sem-burnout/

  #SRE #OnCall #DevOps #Burnout #Operação #Plantão
categories:
  - SRE
tags:
  - serie-sre-na-pratica
  - sre
  - on-call
  - burnout
  - operação
keywords:
  - on-call sre
  - plantão ti
  - burnout sre
  - rotação on-call
autoThumbnailImage: false
thumbnailImagePosition: top
---

On-call é parte essencial da operação de sistemas em produção. Mas on-call mal organizado destrói times. A diferença entre um plantão sustentável e um que causa burnout está na estrutura, não na quantidade de alertas.

<!--more-->

## Os sinais de on-call tóxico

- Mesma pessoa sempre de plantão (porque "só ela sabe")
- Alertas às 3h que poderiam esperar até as 9h
- Sem runbook: cada alerta é uma investigação do zero
- Sem compensação: plantão é "parte do trabalho"
- Falsos positivos constantes: time ignora alertas reais

## Rotação justa

### Regras básicas

| Regra | Por que |
|-------|---------|
| Mínimo 1 semana entre plantões | Recuperação mental |
| Rotação previsível (calendário fixo) | Planejamento pessoal |
| Troca voluntária permitida | Flexibilidade |
| Ninguém de plantão em feriado 2x seguidas | Equidade |
| Backup definido (se primário não responder) | Segurança |

### Para times pequenos (3-5 pessoas)

Com 4 pessoas, cada uma fica de plantão 1 semana por mês. É o mínimo sustentável. Com 3, fica apertado. Considere:

- Plantão apenas em horário comercial estendido (8h-22h)
- Fora do horário: alertas apenas para P1 (serviço completamente fora)
- P2 e P3 esperam até o próximo dia útil

## Runbooks: N1 resolve 80%

O objetivo do runbook é que qualquer pessoa do time consiga resolver os alertas mais comuns sem precisar de conhecimento profundo.

### Estrutura de um runbook

```markdown
# Alerta: [Nome do alerta]

## O que significa
[1-2 frases explicando o que está acontecendo]

## Impacto
[Quem é afetado e como]

## Diagnóstico
1. Verificar [comando]
2. Se resultado X → ir para passo 3
3. Se resultado Y → ir para passo 5

## Resolução
1. [Comando exato]
2. Validar: [comando de validação]
3. Se não resolveu → Escalar para N2

## Escalação
- N2: [nome/canal] se não resolver em 15 min
- N3: [nome/canal] se impacto em produção > 30 min
```

### Top 10 runbooks que todo time precisa

1. Serviço não responde (restart)
2. Disco cheio
3. CPU alta sustentada
4. Memória alta / OOM
5. Certificado SSL expirando
6. Banco de dados lento
7. Fila de mensagens crescendo
8. Deploy falhou
9. DNS não resolve
10. VPN caiu

## Escalação clara

| Nível | Quem | Quando | Tempo de resposta |
|-------|------|--------|-------------------|
| N1 | Plantonista | Alerta automático | 15 min |
| N2 | Especialista do serviço | N1 não resolveu em 15 min | 30 min |
| N3 | Tech Lead / Arquiteto | Impacto em produção > 30 min | 1 hora |
| Gestão | Manager | Incidente P1 > 1 hora | Imediato |

Regra de ouro: **escalar cedo não é fraqueza, é responsabilidade**. Melhor escalar e não precisar do que demorar e o incidente crescer.

## Compensação

On-call sem compensação é exploração. Opções:

| Tipo | Exemplo |
|------|---------|
| Folga compensatória | 1 dia de folga por semana de plantão |
| Adicional financeiro | % sobre o salário na semana de plantão |
| Folga por acionamento | Acionado de madrugada = manhã seguinte livre |
| Banco de horas | Horas de plantão contam como horas extras |

O mínimo: se alguém foi acordado às 3h, não deveria ser cobrado por chegar às 8h.

## Reduzir alertas: a melhor forma de melhorar on-call

Cada alerta falso positivo é dívida de confiança. Depois de 10 falsos positivos, o plantonista começa a ignorar alertas reais.

### Revisão mensal de alertas

```
Para cada alerta que disparou no mês:
1. Foi acionável? (alguém precisou fazer algo?)
2. Era urgente? (precisava ser às 3h ou podia esperar?)
3. O runbook resolveu?
4. Poderia ser auto-resolvido? (autoscaling, restart automático)
```

Alertas que não são acionáveis devem ser removidos ou rebaixados para notificação (não acorda ninguém).

### Classificação de alertas

| Severidade | Ação | Horário |
|-----------|------|---------|
| P1 (serviço fora) | Acorda plantonista | 24/7 |
| P2 (degradado) | Notifica no Slack | Horário comercial |
| P3 (anomalia) | Dashboard/ticket | Próximo dia útil |

## Saúde mental

- **Debrief após incidentes noturnos**: 15 min no dia seguinte para processar
- **Rotação previsível**: Saber quando é seu plantão reduz ansiedade
- **Direito de desconectar**: Fora do plantão = fora do plantão
- **Feedback loop**: Se o on-call está insustentável, o time precisa falar

---

*On-call sustentável não é utopia. É rotação justa, runbooks que funcionam, escalação clara, compensação real e menos alertas falsos. Se o seu time teme o plantão, o problema não é o time. É a estrutura.*
