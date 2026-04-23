---
title: "Se Seu Time Só Cria Dashboards e Gerencia Incidentes, Você Não Tem SRE"
date: 2026-06-03T08:00:00-03:00
description: |
  Toda empresa acha que tem SRE. Poucas realmente têm.

  Se o seu time de SRE passa o dia:
  ❌ Ajustando alertas
  ❌ Coordenando incidentes
  ❌ Criando dashboards bonitos

  Isso é operação sofisticada, não engenharia de confiabilidade.

  A pergunta que importa: o número estrutural de incidentes está caindo? Ou vocês estão apenas ficando melhores em organizar o caos?

  SRE madura responde ao incidente. Mas principalmente altera o sistema para que ele não volte a acontecer.

  Seu time reduz incidentes ou só gerencia eles?

  🔗 https://nerdseverino.com.br/blog/dashboards-nao-e-sre/

  #SRE #Confiabilidade #DevOps #Observabilidade #Engineering
cover:
  image: "/images/uploads/cover-dashboards-sre.png"
  alt: "Cover"
  relative: false
categories:
  - SRE
tags:
  - serie-sre-na-pratica
  - sre
  - confiabilidade
  - cultura
  - engenharia
keywords:
  - sre verdadeiro
  - engenharia confiabilidade
  - toil
  - error budget
autoThumbnailImage: false
thumbnailImagePosition: top
---

"SRE is what happens when you ask a software engineer to design an operations team." A palavra central é design. O SRE projeta mecanismos. Ele não é um observador passivo do sistema.

<!--more-->

## O teste desconfortável

Responda honestamente:

1. O número de incidentes está diminuindo mês a mês?
2. Existe rollback automático?
3. Existe error budget visível que bloqueia deploy?
4. Timeout e retry são padrão obrigatório em toda comunicação entre serviços?
5. O desenvolvedor recebe alerta da própria aplicação?

Se a resposta for "não" para a maioria: você tem um time de suporte sofisticado, não um time de SRE.

## Gerenciar incidente vs reduzir incidente

| Gerenciar incidente | Reduzir incidente |
|--------------------|--------------------|
| Melhora MTTR | Muda arquitetura |
| Estrutura postmortem | Implementa ações do postmortem |
| Cria dashboards | Cria mecanismos automáticos |
| Coordena comunicação | Elimina a necessidade de coordenar |
| Reativo | Proativo |

Gerenciar incidente faz parte do trabalho. Mas se é o núcleo do trabalho, o sistema não está evoluindo.

## Toil: o sintoma de falha estrutural

O Google define toil como trabalho manual, repetitivo e reativo que não agrega valor duradouro.

Exemplos de toil:
- Reiniciar serviço manualmente toda semana
- Ajustar alarme que dispara falso positivo
- Rodar script de limpeza de disco todo mês
- Escalar incidente que poderia ser auto-resolvido

Se o time passa mais de 50% do tempo em toil, não sobra tempo para engenharia. E sem engenharia, o toil só aumenta.

### Como medir toil

```
% toil = horas em trabalho repetitivo / horas totais do time

Meta Google: < 50% toil
Meta ideal: < 30% toil
```

Cada tarefa repetitiva é candidata a automação. Priorize pela frequência x tempo gasto.

## Mecanismos vs emoções

Em organizações com alta maturidade, confiabilidade não é conversa de corredor. É política codificada.

**Error Budget não é slide. É mecanismo.**

Se o SLO é 99.9% e o budget de erro acabou, o deploy congela. Não tem reunião. Não tem "vamos analisar". É o mecanismo protegendo o sistema.

**Blast radius não é teoria.**

Sistemas projetados para falhar pequeno:
- Células independentes
- Dependências isoladas
- Impacto limitado automaticamente

A pergunta não é "como não cair?" É "quanto impacto essa falha pode causar?"

## O caminho de operação para SRE

### Fase 1: Visibilidade (mês 1-2)
- SLIs definidos (disponibilidade, latência, erro)
- Dashboard operacional funcional
- Alertas baseados em sintoma

### Fase 2: Resposta (mês 3-4)
- Postmortem blameless após cada incidente
- Runbooks para os top 10 incidentes
- On-call estruturado

### Fase 3: Prevenção (mês 5-6)
- Ações de postmortem implementadas (não só documentadas)
- Automação dos top 5 toils
- Error budget definido e acompanhado

### Fase 4: Engenharia (mês 7+)
- Mecanismos automáticos (rollback, circuit breaker, autoscaling)
- Chaos engineering (testar falhas intencionalmente)
- Número de incidentes caindo mês a mês

## Checklist: seu time é SRE ou operação?

- [ ] Incidentes estão diminuindo (não só sendo gerenciados melhor)
- [ ] Ações de postmortem são implementadas (não só documentadas)
- [ ] Toil é medido e está diminuindo
- [ ] Error budget existe e influencia decisões
- [ ] Time escreve código (automação, ferramentas, mecanismos)
- [ ] Desenvolvedores são donos da confiabilidade das suas aplicações

---

*SRE não é cargo. É prática. Se o seu time só apaga incêndio e cria dashboard, comece medindo toil, implementando ações de postmortem e automatizando o repetitivo. A evolução de operação para SRE é gradual, mas começa com a decisão de parar de só reagir e começar a projetar confiabilidade.*
