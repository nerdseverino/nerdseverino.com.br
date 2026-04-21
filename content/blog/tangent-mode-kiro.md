---
title: "Tangent Mode no Kiro CLI: Consultas sem Poluir o Contexto"
date: 2026-05-22T08:00:00-03:00
description: |
  Você está no meio de um troubleshooting complexo e precisa pesquisar algo rápido. Abre uma nova aba? Perde o contexto.

  Tangent Mode resolve: uma conversa paralela que não afeta a principal.

  🔀 Pesquisar sintaxe de um comando sem perder o fluxo
  🔀 Consultar documentação sem poluir o contexto
  🔀 Testar uma ideia sem comprometer a investigação

  Quando termina, volta exatamente onde parou.

  Como você lida com pesquisas paralelas durante troubleshooting?

  🔗 https://nerdseverino.com.br/blog/tangent-mode-kiro/

  #KiroCLI #AI #Produtividade #DevTools #SRE
categories:
  - DevOps
  - Ferramentas
tags:
  - serie-kiro-cli
  - kiro
  - tangent-mode
  - produtividade
keywords:
  - kiro tangent mode
  - contexto ia
  - conversa paralela
autoThumbnailImage: false
thumbnailImagePosition: top
---

No meio de um troubleshooting complexo, você precisa verificar a sintaxe de um comando. Ou consultar uma documentação. Ou testar uma hipótese rápida. Se faz isso na mesma conversa, polui o contexto e o Kiro perde o fio da meada. Tangent Mode resolve isso.

<!--more-->

## O problema do contexto poluído

Assistentes AI mantêm contexto da conversa. Cada mensagem adiciona informação que influencia as respostas seguintes. Isso é ótimo para manter coerência, mas péssimo quando você precisa fazer um desvio rápido.

Exemplo real:
1. Você está investigando um problema de rede complexo
2. Precisa verificar a sintaxe do `iptables` para uma regra específica
3. Pergunta sobre iptables na mesma conversa
4. O Kiro agora mistura o contexto de rede com iptables
5. As respostas seguintes ficam confusas

## Como funciona o Tangent Mode

O Tangent Mode abre uma conversa paralela isolada. O contexto da conversa principal fica congelado. Quando você termina o tangent, volta exatamente onde parou.

```
# Na conversa principal (investigando problema de rede)
> "O ALB está retornando 502 para o target group..."

# Precisa verificar algo rápido
> Shift+Tab (abre Tangent Mode)

# Conversa paralela (contexto isolado)
> "Qual a sintaxe do curl para testar com header Host específico?"
> "curl -H 'Host: api.exemplo.com' http://10.0.1.50:8080/health"

# Volta para a conversa principal
> Shift+Tab (fecha Tangent)

# Contexto original preservado
> "Testei com curl e o target responde 200 localmente..."
```

## Quando usar

**Pesquisa de sintaxe**: Verificar flags de um comando sem sair do fluxo.

**Consulta de documentação**: "Como funciona o parâmetro X do CloudWatch?" sem misturar com a investigação atual.

**Teste de hipótese**: "Se eu mudar o security group para permitir porta 8080, quais são os riscos?" sem comprometer a análise principal.

**Cálculos rápidos**: "Quantos GB são 1.5 TB?" ou "Qual o CIDR para 10.0.0.0 com 512 hosts?"

**Tradução/formatação**: Formatar um JSON, converter timestamp, gerar regex.

## Tangent vs Nova sessão

| Aspecto | Tangent Mode | Nova sessão |
|---------|-------------|-------------|
| Contexto principal | Preservado | Perdido |
| Velocidade | Instantâneo | Precisa recarregar |
| Memória/steering | Compartilhado | Compartilhado |
| Uso | Desvios rápidos | Tarefas independentes |

Use Tangent para desvios de 1-5 minutos. Para tarefas longas e independentes, abra uma nova sessão com `/chat new` ou `/spawn`.

## Dicas práticas

1. **Mantenha tangents curtos**: 2-3 perguntas no máximo. Se precisa de mais, é uma nova tarefa.
2. **Use para validar antes de executar**: Teste um comando no tangent antes de rodar na conversa principal.
3. **Combine com /spawn**: Para tarefas paralelas mais longas, use `/spawn` ao invés de tangent.

---

*Tangent Mode é uma daquelas features que parece pequena mas muda o workflow. A capacidade de fazer desvios sem perder contexto elimina a fricção de pesquisar durante investigações complexas.*
