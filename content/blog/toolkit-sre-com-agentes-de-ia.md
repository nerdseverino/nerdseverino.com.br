---
title: "Construí meu próprio toolkit de SRE com agentes de IA"
cover:
  image: /images/uploads/toolkit-sre-com-agentes-de-ia.jpeg
  alt: "Construí meu próprio toolkit de SRE com agentes de IA"
date: 2026-10-19T10:40:00-03:00
description: |
  Enquanto discutem se IA vai substituir SRE, eu construí agentes que fazem meu toil.

  IA em operações não é chatbot. É automação de verdade:

  🎫 Consultar e atualizar tickets por conversa
  📊 Buscar métricas de monitoramento sem abrir o console
  💬 Ler grupos e mandar notificação
  📅 Resumo diário cruzando 5 fontes: de 30min para 2min

  Construí 4 integrações próprias (MCP). O humano decide, o agente faz o chato.

  O ponto não é a IA ser esperta. É eu parar de fazer toil.

  Qual é a tarefa manual que mais te irrita no dia a dia? (a minha era o resumo diário, cruzando 5 fontes na mão)

  #SRE #AI #DevOps #Automação
categories:
  - SRE
  - Ferramentas
tags:
  - sre
  - ia
  - automação
  - mcp
  - produtividade
keywords:
  - agentes de ia sre
  - mcp model context protocol
  - automação operações
  - ai ops
  - toil automação ia
autoThumbnailImage: false
thumbnailImagePosition: top
---

A discussão sobre IA e SRE geralmente trava em "a IA vai substituir engenheiros?". Pergunta errada. A pergunta útil é: o que da minha rotina é toil repetitivo que uma IA com as ferramentas certas poderia fazer, me liberando para o trabalho que exige julgamento? Enquanto o debate rolava, eu fui construindo. Hoje tenho um toolkit de agentes que faz o meu chato.

<!--more-->

## O que IA em operações não é

Não é um chatbot que responde perguntas genéricas sobre Linux. Isso é o óbvio e pouco útil para quem já é da área.

IA em operações, de verdade, é dar ao assistente **ferramentas** para interagir com os sistemas que você usa. É aí que entra o MCP (Model Context Protocol): um padrão que permite ao agente consultar, criar e atualizar coisas em sistemas externos de forma controlada.

A diferença entre "me explique como funciona um sistema de tickets" e "liste meus chamados abertos e adicione uma nota no ticket X" é a diferença entre um chatbot e um agente operacional.

## O que eu construí

Montei integrações próprias (MCPs) para as ferramentas que uso todo dia:

| Integração | O que faz |
|------------|-----------|
| Tickets | Consulta, cria e atualiza chamados por conversa |
| Mensageria | Lê grupos de operação e envia notificações |
| Workspace | Acessa documentos e planilhas de contexto |
| Chat corporativo | Lê canais e posta atualizações |

Cada uma elimina um pedaço de troca de contexto. Antes eu alternava entre console de monitoramento, sistema de tickets, chat e planilha. Agora pergunto em linguagem natural e o agente busca na fonte certa.

## O caso que mais me economiza tempo: o resumo diário

Todo dia eu precisava montar um resumo do que estava acontecendo: tickets abertos, atividades minhas e de outros técnicos, menções em grupos, pendências. Isso envolvia cruzar 5 fontes diferentes manualmente. Levava cerca de 30 minutos.

Com os agentes, viram 2 minutos. O agente consulta as 5 fontes, cruza os dados, e me entrega o resumo consolidado. Eu reviso e ajusto.

Fazendo a conta: ~28 minutos economizados por dia útil, por pessoa. Em um mês, são mais de 9 horas. Quase um dia e meio de trabalho recuperado, todo mês, só nessa tarefa.

## O princípio: o humano decide, o agente executa o chato

Aqui está o equilíbrio que torna isso seguro e útil. O agente não toma decisões de risco sozinho. Ele:

- **Coleta** informação (consulta tickets, métricas, mensagens)
- **Correlaciona** dados de fontes diferentes
- **Prepara** o trabalho (draft de resumo, rascunho de resposta)
- **Executa** tarefas repetitivas com meu aval

O que continua comigo:
- A decisão sob incerteza
- O julgamento de prioridade
- A responsabilidade quando algo dá errado

Para ações que mexem com o mundo real (enviar mensagem, fechar ticket), uso guardrails: o agente mostra o que vai fazer e espera confirmação. Nunca age cego em algo irreversível.

## Por que isso importa para quem é SRE

O trabalho de SRE tem muito toil escondido: tarefas manuais, repetitivas, que não agregam valor duradouro mas consomem tempo. O próprio Google define toil como sintoma de falha estrutural.

Agentes de IA são uma alavanca nova contra o toil. Não substituem a engenharia (projetar sistemas, decidir arquitetura, responder incidente), mas devoram o trabalho mecânico que fica no meio.

E tem um diferencial: quase ninguém no Brasil está escrevendo sobre isso com prática real. A maioria discute IA no abstrato. Construir e usar no dia a dia é o que separa opinião de experiência.

## Como começar

Se você quer trilhar esse caminho:

1. **Mapeie seu toil**: liste as tarefas repetitivas que você faz toda semana
2. **Identifique as fontes**: quais sistemas você consulta repetidamente?
3. **Comece pequeno**: automatize uma consulta (ex: "liste meus tickets abertos")
4. **Adicione guardrails**: ações destrutivas sempre com confirmação
5. **Meça o tempo economizado**: justifica o investimento e mostra o impacto

## O ponto final

O medo de ser substituído por IA é compreensível, mas improdutivo. A postura que funciona é: use a IA para eliminar o seu toil, e invista o tempo recuperado no trabalho que exige o que a máquina não tem, julgamento, contexto e responsabilidade.

O agente não é esperto o suficiente para fazer meu trabalho. Mas é esperto o suficiente para fazer o chato dele. E isso já muda a escala do que eu consigo entregar.

---

*A IA não vai substituir o SRE que entende de sistemas. Vai amplificar o SRE que souber delegar o toil para ela. Construí meu toolkit porque esperar a ferramenta perfeita chegar pronta é desperdício. O humano decide, o agente faz o chato, e eu ganho horas de volta todo mês. Essa é a operação aumentada por IA que realmente funciona.*
