---
title: "Postmortem Blameless: Aprendendo com o Caos sem Procurar Culpado"
date: 2026-04-29T08:00:00-03:00
description: |
  Seu time teve um incidente grave. O que acontece depois?

  Se a resposta é "procurar quem errou", você está destruindo a confiança do time.

  Postmortem blameless troca "quem errou?" por:
  ⚡ Por que essa decisão fez sentido naquele momento?
  ⚡ Que informação faltava?
  ⚡ Que processo deveria ter protegido o sistema?

  A gente não conserta pessoas. A gente melhora sistemas e processos.

  O post tem template prático, exemplos reais e o checklist que uso após cada incidente.

  Como seu time lida com postmortems hoje?

  🔗 https://nerdseverino.com.br/blog/postmortem-blameless/

  #SRE #Postmortem #IncidentManagement #DevOps #Confiabilidade
cover:
  image: "/images/uploads/cover-postmortem.png"
  alt: "Cover"
  relative: false
categories:
  - SRE
tags:
  - serie-sre-na-pratica
  - sre
  - postmortem
  - incidentes
  - confiabilidade
keywords:
  - postmortem blameless
  - incident management
  - root cause analysis
  - sre
autoThumbnailImage: false
thumbnailImagePosition: top
---

Incidentes acontecem. A diferença entre times que evoluem e times que repetem os mesmos erros está no que fazem depois. O postmortem blameless é a ferramenta mais poderosa que um time de SRE tem para transformar falhas em aprendizado.

<!--more-->

## Por que blameless?

Culpar alguém após um incidente gera medo. Medo gera silêncio. Silêncio esconde sinais importantes. As pessoas começam a maquiar sintomas, evitar riscos e o ciclo se repete.

A premissa do blameless é simples: quem estava ali fez o melhor que podia com a informação que tinha naquele momento.

Não significa que não há responsabilidade. Significa que a responsabilidade é do sistema, não do indivíduo. Se uma pessoa conseguiu derrubar produção com um comando, o problema é que o sistema permitiu isso.

## Estrutura de um postmortem que funciona

### 1. Resumo do Incidente

- Data e horário de início e fim
- Serviços impactados
- Quem foi afetado (usuários internos/externos)
- Descrição clara e objetiva do que aconteceu

### 2. Linha do Tempo

Liste os eventos em ordem cronológica:

| Horário | Evento |
|---------|--------|
| 14:32 | Alarme de error rate disparou |
| 14:35 | SRE de plantão reconheceu o alarme |
| 14:38 | Identificado deploy recente como possível causa |
| 14:42 | Rollback iniciado |
| 14:47 | Serviço restaurado |
| 14:50 | Alarme resolvido |

Construa isso com o time logo após o incidente, enquanto a memória está fresca.

### 3. Impacto

- Porcentagem de requisições afetadas
- Duração da degradação
- Impacto em SLOs
- Como o usuário percebeu (erros, lentidão, indisponibilidade)

### 4. Causa Raiz

- O que iniciou o problema?
- Por que não foi contido antes?
- Que decisões técnicas ou operacionais permitiram isso?

Vá além do óbvio. "O deploy quebrou" não é causa raiz. "O deploy não tinha validação de health check antes de rotacionar tráfego" é.

### 5. O que Funcionou Bem

Reconhecer o que funcionou também faz parte:
- Alertas acionaram corretamente?
- Alguém agiu rápido com conhecimento crítico?
- Runbooks ajudaram?
- Rollback foi efetivo?

### 6. Onde Podemos Melhorar

- Alertas ausentes ou ignorados?
- Escalação lenta?
- Comunicação fragmentada?
- Troubleshooting difícil por falta de logs ou métricas?
- Runbooks desatualizados?
- Falta de ownership claro?

### 7. Ações (a parte mais importante)

Cada ação deve ter:
- Descrição específica (não "melhorar monitoramento")
- Responsável com nome
- Prazo
- Prioridade

Exemplo:

| Ação | Responsável | Prazo | Prioridade |
|------|-------------|-------|------------|
| Adicionar health check no pipeline de deploy | Time Platform | 2 semanas | Alta |
| Criar alarme para latência p99 do checkout | SRE | 1 semana | Alta |
| Documentar runbook de rollback do serviço X | SRE | 1 semana | Média |
| Revisar timeout entre serviço A e banco | Time Backend | 3 semanas | Média |

## Template prático

```markdown
# Postmortem: [Título descritivo do incidente]

**Data**: YYYY-MM-DD
**Duração**: HH:MM a HH:MM (X minutos)
**Severidade**: P1/P2/P3
**Autor**: [Nome]

## Resumo
[2-3 frases descrevendo o que aconteceu]

## Impacto
- Usuários afetados: X%
- Duração: X minutos
- SLO impactado: [qual]

## Linha do Tempo
| Horário | Evento |
|---------|--------|
| HH:MM | ... |

## Causa Raiz
[Descrição técnica da causa]

## O que Funcionou
- ...

## O que Podemos Melhorar
- ...

## Ações
| Ação | Responsável | Prazo | Status |
|------|-------------|-------|--------|
| ... | ... | ... | Pendente |
```

## Erros comuns em postmortems

**"Erro humano" como causa raiz**: Se alguém rodou o comando errado, por que o sistema permitiu? Onde estava a validação? O guardrail?

**Ações vagas**: "Melhorar monitoramento" não é ação. "Criar alarme de error rate > 1% no serviço X com notificação no PagerDuty" é ação.

**Postmortem sem follow-up**: De nada adianta documentar ações se ninguém acompanha. Revise as ações na weekly do time.

**Só fazer postmortem de P1**: Incidentes menores também ensinam. Se o mesmo P3 acontece toda semana, merece um postmortem.

## Como conduzir a reunião

1. **Facilitador neutro** (não o envolvido direto no incidente)
2. **Foco em fatos**, não em opiniões ("o log mostra X" vs "eu acho que foi Y")
3. **Sem interrupções** durante a construção da timeline
4. **Máximo 1 hora** (se precisar de mais, agende continuação)
5. **Publicar o documento** para toda a organização (transparência)

## Quando fazer postmortem

- Todo incidente P1 e P2
- Incidentes P3 recorrentes (mesmo problema 3+ vezes)
- Near-misses (quase deu problema, mas foi pego a tempo)
- Quando o time pedir (qualquer pessoa pode solicitar)

---

*Postmortem não é burocracia. É o mecanismo que transforma dor em evolução. Se seu time ainda procura culpados após incidentes, talvez seja hora de mudar a abordagem. O sistema falhou, não a pessoa.*
