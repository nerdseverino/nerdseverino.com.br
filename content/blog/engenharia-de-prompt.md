---
title: "Engenharia de Prompt: Estruturando Prompts como Algoritmos"
date: 2026-05-29T08:00:00-03:00
draft: true
description: |
  A diferença entre um prompt que funciona e um que não funciona raramente é o conteúdo. É a estrutura.

  Prompts bem estruturados são como algoritmos:
  ⚡ Entrada clara (contexto + dados)
  ⚡ Processamento definido (instruções específicas)
  ⚡ Saída esperada (formato + restrições)

  Técnicas que uso diariamente:
  📋 Role + Context + Task + Format
  📋 Chain of thought para problemas complexos
  📋 Few-shot com exemplos reais
  📋 Constraints para evitar respostas genéricas

  Qual prompt você mais usa no dia a dia?

  🔗 https://nerdseverino.com.br/blog/engenharia-de-prompt/

  #PromptEngineering #AI #Produtividade #KiroCLI #DevTools
categories:
  - DevOps
  - Ferramentas
tags:
  - prompt
  - ia
  - produtividade
  - kiro
keywords:
  - engenharia de prompt
  - prompt engineering
  - prompt estruturado
autoThumbnailImage: false
thumbnailImagePosition: top
---

A maioria das pessoas escreve prompts como se estivesse conversando casualmente. Funciona para perguntas simples, mas para tarefas complexas o resultado é inconsistente. Prompts bem estruturados são como algoritmos: entrada definida, processamento claro, saída previsível.

<!--more-->

## O framework: Role + Context + Task + Format

Todo prompt eficiente tem quatro componentes:

| Componente | Função | Exemplo |
|-----------|--------|---------|
| **Role** | Quem a AI deve ser | "Você é um SRE sênior" |
| **Context** | Informação relevante | "Temos 20 EC2 em 3 contas AWS" |
| **Task** | O que fazer | "Identifique instâncias candidatas a rightsizing" |
| **Format** | Como entregar | "Tabela com instância, CPU média, recomendação" |

### Prompt ruim

```
Me ajuda com os custos da AWS
```

### Prompt bom

```
Você é um especialista FinOps.

Contexto: Temos 20 instâncias EC2 na conta de produção,
a maioria m5.xlarge. O custo mensal está em $4.500.
CPU média do último mês ficou abaixo de 25% em 15 delas.

Tarefa: Identifique as instâncias candidatas a rightsizing
e calcule a economia estimada.

Formato: Tabela com colunas: tipo atual, CPU média,
tipo recomendado, economia mensal estimada.
```

A diferença não é quantidade de texto. É clareza de expectativa.

## Técnicas avançadas

### Chain of Thought

Para problemas complexos, peça para a AI pensar passo a passo:

```
Analise este incidente passo a passo:

1. Primeiro, identifique os sintomas nos logs
2. Depois, correlacione com mudanças recentes
3. Formule 3 hipóteses de causa raiz
4. Para cada hipótese, sugira como validar
5. Recomende a ação mais provável

Logs:
[colar logs aqui]
```

### Few-shot (exemplos)

Mostre exemplos do formato que espera:

```
Crie alertas CloudWatch seguindo este padrão:

Exemplo:
Nome: prod-api-error-rate-high
Métrica: HTTPCode_Target_5XX_Count
Threshold: > 10 por 3 minutos
Ação: SNS topic prod-alerts

Agora crie alertas para:
- Latência p99 do ALB acima de 500ms
- CPU do RDS acima de 80%
- Fila SQS com mais de 1000 mensagens
```

### Constraints (restrições)

Restrições evitam respostas genéricas:

```
Crie um runbook para restart do serviço de API.

Restrições:
- Máximo 10 passos
- Cada passo deve ter o comando exato (copy-paste)
- Incluir validação após cada passo
- Não usar sudo desnecessariamente
- Tempo estimado: menos de 5 minutos
```

### Template com variáveis

Crie prompts reutilizáveis:

```
Analise o custo AWS do serviço {SERVICO} na conta {CONTA}.

Período: último mês
Foco: identificar os 3 maiores gastos e sugerir otimizações.
Formato: resumo executivo (3 parágrafos) + tabela de ações.
Restrições: apenas sugestões que não exigem mudança de arquitetura.
```

## Prompts para SRE no dia a dia

### Análise de incidente

```
Analise este incidente como um SRE sênior.

Timeline:
[colar eventos]

Responda:
1. Causa raiz provável
2. Por que não foi detectado antes
3. 3 ações preventivas (específicas, com responsável sugerido)
```

### Criação de runbook

```
Crie um runbook para: [procedimento]

Formato:
- Título e objetivo
- Pré-requisitos
- Passos numerados com comandos exatos
- Validação após cada passo crítico
- Rollback se algo der errado
- Tempo estimado
```

### Revisão de configuração

```
Revise esta configuração de [serviço] para produção.

[colar config]

Verifique:
- Segurança (credenciais expostas, permissões excessivas)
- Performance (timeouts, pool sizes, limites)
- Resiliência (retry, circuit breaker, fallback)
- Observabilidade (logs, métricas, health check)
```

## Anti-patterns

**Prompt vago**: "Me ajuda com isso" → A AI não sabe o que "isso" é nem o que "ajuda" significa.

**Contexto demais**: 5 páginas de contexto para uma pergunta simples → A AI se perde no ruído.

**Sem formato esperado**: Não especificar formato → Cada resposta vem diferente.

**Prompt único para tudo**: Tentar resolver problema complexo em uma mensagem → Quebre em etapas.

## Prompts como código

Trate prompts importantes como código:

- Versione (salve em arquivos, git)
- Teste (rode o mesmo prompt 3 vezes, resultado deve ser consistente)
- Itere (melhore baseado nos resultados)
- Documente (por que esse prompt existe, quando usar)

No Kiro CLI, você pode salvar prompts como arquivos e referenciar com `@prompt-name`:

```bash
# Criar prompt reutilizável
# ~/.kiro/prompts/analise-custo.md
# Depois usar: @analise-custo "conta-prod"
```

---

*Engenharia de prompt não é sobre escrever mais. É sobre estruturar melhor. Role + Context + Task + Format resolve 90% dos casos. Para o resto, chain of thought, few-shot e constraints refinam o resultado. Trate prompts como algoritmos e os resultados se tornam previsíveis.*
