---
title: "O bug que fingiu que 66 bancos pararam de ser monitorados"
cover:
  image: /images/uploads/bug-66-bancos-monitoramento.jpeg
  alt: "O bug que fingiu que 66 bancos pararam de ser monitorados"
date: 2026-10-14T17:00:00-03:00
description: |
  "Os bancos pararam de ser monitorados." A métrica que importava estava OK o tempo todo.

  Um alerta disparou dizendo que 66 instâncias RDS tinham parado de ser monitoradas. Pânico. Mas o monitoramento real nunca parou.

  O que eu aprendi caçando esse bug:

  🔍 Diagnóstico superficial trata sintoma
  🎯 Diagnóstico real separa o que falhou do que só PARECEU falhar
  🧬 Fix na fonte (template) corrige a frota inteira, não host a host

  A causa raiz? Um XML vazio e um forEach sobre string.

  Você já perseguiu um alerta que mentia?

  #SRE #Observabilidade #Debugging #Zabbix #DevOps #Troubleshooting
categories:
  - SRE
  - Observabilidade
tags:
  - sre
  - debugging
  - observabilidade
  - zabbix
  - troubleshooting
keywords:
  - debug alerta falso
  - zabbix trigger
  - monitoramento rds
  - diagnóstico root cause
  - corrigir na fonte template
autoThumbnailImage: false
thumbnailImagePosition: top
---

Me chamaram com a frase que gela qualquer SRE: "66 instâncias de banco pararam de ser monitoradas". Um alerta tinha disparado em massa. A reação natural é pânico. Mas antes de panicar, uma pergunta: a métrica que realmente importa parou? Spoiler: não parou. O monitoramento estava funcionando o tempo todo. O que falhou foi outra coisa.

<!--more-->

## O sintoma

Um alerta disparou indicando que 66 instâncias RDS, numa operação multi-tenant, tinham perdido o monitoramento. Em volume, parece catástrofe: 66 bancos cegos ao mesmo tempo.

O diagnóstico superficial seria sair reiniciando agentes, recriando itens, host a host, 66 vezes. Horas de trabalho tratando o sintoma.

## A primeira pergunta certa

Antes de agir, separei duas coisas que o pânico mistura:

1. O que **realmente** falhou?
2. O que só **pareceu** falhar?

Fui direto na métrica que importa: as instâncias estavam reportando dados? Sim. CPU, conexões, storage, tudo chegando normalmente. O monitoramento de verdade nunca parou.

Então o que disparou o alerta? Um trigger específico, de uma categoria de "disaster recovery", estava travado em estado de erro. Ele dizia "parou de monitorar", mas era ele mesmo que estava quebrado, não o monitoramento.

O alerta estava mentindo.

## A caça à causa raiz

Com a certeza de que era o trigger (e não os 66 bancos), fui atrás do porquê. O trigger dependia de um item que processava uma resposta XML de uma API.

O problema: quando não havia eventos para processar, a API retornava um XML **vazio** no formato `<Events/>`. O código que processava isso fazia um `forEach` esperando uma lista de eventos. Mas com o XML vazio, em vez de uma lista vazia, o parser entregava uma **string**. O `forEach` sobre uma string quebrava, o item ia para estado de erro, e o trigger de disaster disparava o falso alarme.

```text
Esperado: <Events><Event>...</Event></Events> → lista → forEach OK
Recebido: <Events/>                            → string → forEach quebra
```

Um edge case bobo (ausência de eventos) derrubava a lógica inteira e gerava pânico em massa.

## O fix que importa: na fonte

Aqui está a parte que separa diagnóstico de verdade de remendo. Eu poderia ter corrigido host a host, 66 vezes. Mas os 66 hosts compartilhavam o mesmo **template**.

O bug estava no template, não nos hosts. Corrigir o parsing no template (tratar o caso do XML vazio retornando uma lista vazia em vez de string) resolveu a frota inteira de uma vez. Um fix, 66 hosts corrigidos.

E mais: qualquer host novo criado a partir daquele template já nasce corrigido. O problema não volta.

## As lições

**1. Alerta pode mentir.** A primeira pergunta num alerta em massa não é "como conserto?", é "isso é real?". Separe o que falhou do que só pareceu falhar.

**2. A métrica que importa é a âncora.** Enquanto o monitoramento real estava entregando dados, não havia catástrofe. Ancore o diagnóstico no que realmente mede a saúde do sistema, não no alerta que gritou.

**3. Edge case é onde mora o bug.** XML vazio, lista vazia, resposta nula. O caminho feliz quase sempre funciona. O bug mora no "e quando não tem nada para processar?".

**4. Corrija na fonte, não no sintoma.** Quando N recursos compartilham uma origem comum (template, módulo, imagem base), o fix pertence à fonte. Corrigir host a host é tratar sintoma. Corrigir o template é curar a frota.

## O princípio por trás

Isso vale muito além de monitoramento. Toda vez que você vê o mesmo problema se repetindo em N lugares, pare antes de corrigir o primeiro. Pergunte: esses N lugares têm uma origem comum? Se têm, o fix está lá, não em cada instância.

É a diferença entre apagar 66 incêndios e consertar a fiação que causava todos eles.

---

*O trabalho de SRE não é reagir rápido ao alerta. É ter o método para questionar o alerta, separar sinal de ruído, e corrigir onde o problema realmente nasce. 66 bancos "pararam de ser monitorados" e nenhum deles tinha parado. A diferença entre horas de trabalho e um fix de minutos estava em fazer a pergunta certa antes de agir.*
