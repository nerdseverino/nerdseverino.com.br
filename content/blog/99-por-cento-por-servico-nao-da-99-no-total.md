---
title: "Cada time jura que tem 99%: a matemática da disponibilidade que ninguém faz"
cover:
  image: /images/uploads/99-por-cento-por-servico-nao-da-99-no-total.jpeg
  alt: "Cada time jura que tem 99%: a matemática da disponibilidade que ninguém faz"
date: 2026-11-12T08:11:23-03:00
description: |
  Todo time mostra seu 99%. O usuário ainda vê erro. A conta não fecha, e tem motivo.

  ❌ Soma ou tira média de disponibilidade em vez de multiplicar.
  ❌ Acoplamento síncrono: a falha de um serviço derruba o fluxo inteiro.
  ❌ Acha que 99% por serviço basta, sem contar quantos saltos a requisição faz.
  ❌ Mede por componente e nunca pela jornada ponta-a-ponta.

  Disponibilidade não é média. É produto. 99% cinco vezes vira 95%.

  A virada: reduzir saltos síncronos, desacoplar o que dá e degradar com elegância em vez de cuspir 500. Arquitetura moderna não conserta acoplamento lógico ruim.

  Já te mostraram dashboards todos verdes enquanto o usuário jurava que o sistema estava fora?

  #SRE #SLO #Confiabilidade #Arquitetura
categories:
  - SRE
tags:
  - sre
  - slo
  - disponibilidade
  - arquitetura
keywords:
  - disponibilidade composta
  - slo
  - acoplamento sincrono
  - error budget
  - confiabilidade
autoThumbnailImage: false
thumbnailImagePosition: top
---

A reunião começa com todo mundo mostrando seu número. O time de pagamento tem 99%. O de estoque tem 99%. O de autenticação, 99%. Todos os dashboards verdes, todos os SLOs "batidos", e mesmo assim, do outro lado da tela, o usuário clica em finalizar compra e recebe erro. Alguém pergunta como isso é possível se está tudo verde. Ninguém responde, porque ninguém fez a conta.

<!--more-->

## A matemática que ninguém faz

O erro começa na aritmética. Quando um serviço depende de outro de forma síncrona (ele precisa da resposta para continuar), as disponibilidades não se somam nem tiram média: elas se multiplicam. Um checkout que chama cinco serviços síncronos, cada um com 99%, não entrega 99%. Entrega 0,99 elevado a cinco.

| Saltos síncronos | Conta | Disponibilidade real |
|---|---|---|
| 1 | 0,99 | 99,0% |
| 3 | 0,99³ | 97,0% |
| 5 | 0,99⁵ | ~95,1% |

Cinco times entregando "99%" produzem uma jornada de ~95%. A diferença entre 99% e 95% parece pequena no papel, mas são semanas de indisponibilidade a mais por ano, bem na frente do usuário que paga.

## Por que o acoplamento síncrono amplifica

Cada dependência síncrona é um elo que precisa estar de pé ao mesmo tempo. Basta um cair para a requisição inteira falhar. É por isso que multiplicar faz sentido: a jornada só funciona quando todos os elos funcionam juntos, e a probabilidade disso acontecer encolhe a cada salto novo. Mais dependências na rota crítica significam menos disponibilidade composta, mesmo que cada peça esteja ótima isoladamente.

## Medir por componente engana

O dashboard verde por serviço responde "meu pedaço está de pé?". É a pergunta errada. A pergunta que importa é "o usuário conseguiu fazer o que veio fazer?". Quando você mede por componente, cada time otimiza o próprio quadrado e ninguém é dono da jornada inteira. A disponibilidade que conta é a da jornada ponta-a-ponta, a do fluxo de login ou de checkout visto da perspectiva de quem clica, não a média aritmética dos SLOs de cada caixinha.

## A virada

Reduzir o número de saltos síncronos na rota crítica é o ganho mais direto: cada elo a menos devolve pontos de disponibilidade. Onde o salto não precisa ser imediato, desacople (fila, evento, processamento assíncrono) para que a falha de uma dependência não derrube o fluxo principal. E, quando algo cair mesmo assim, prefira degradação graciosa (mostrar um estado parcial, enfileirar e confirmar depois) em vez de devolver um 500. Uma ressalva honesta: arquitetura moderna não resolve acoplamento lógico ruim. Microserviços e malha de serviços só tornam o mesmo erro mais caro de debugar.

## O checklist da disponibilidade real

- [ ] Você sabe quantos saltos síncronos sua requisição crítica faz?
- [ ] Multiplicou as disponibilidades da cadeia em vez de tirar média?
- [ ] Mede pela jornada do usuário ou só por componente?
- [ ] Dá para desacoplar algum salto (assíncrono ou fila)?
- [ ] Tem degradação graciosa no lugar do erro 500?

*Verde em cada caixinha não é verde na jornada. Enquanto você somar disponibilidade em vez de multiplicar, o dashboard vai continuar mentindo com a melhor das intenções.*
