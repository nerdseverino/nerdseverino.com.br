---
title: "Kiro CLI Skills: As 8 Skills que Uso no Dia a Dia como SRE"
description: |
  Se você usa o Kiro CLI e ainda não explorou o sistema de skills, está deixando poder na mesa. Skills são como "módulos de conhecimento especializado" que o Kiro carrega sob demanda — ele sabe quando ativar cada uma com base no que você pede. Neste artigo, compartilho as 8 skills que fazem parte do meu setup diário como SRE.

  🔗 https://nerdseverino.com.br/blog/kiro-cli-skills-que-uso-no-dia-a-dia/
date: 2026-03-29T21:26:00-03:00
categories:
  - DevOps
  - Ferramentas
tags:
  - serie-kiro-cli
  - kiro
  - cli
  - ia
  - produtividade
  - sre
  - skills
keywords:
  - kiro cli skills
  - kiro skills
  - inteligencia artificial
  - automacao sre
  - produtividade devops
autoThumbnailImage: false
thumbnailImagePosition: top
---

Se você usa o Kiro CLI e ainda não explorou o sistema de skills, está deixando poder na mesa. Skills são como "módulos de conhecimento especializado" que o Kiro carrega sob demanda — ele sabe quando ativar cada uma com base no que você pede. Neste artigo, compartilho as 8 skills que fazem parte do meu setup diário como SRE.

<!--more-->

## O que são Skills no Kiro?

Skills ficam em `~/.kiro/skills/` e cada uma tem um arquivo `SKILL.md` com instruções, exemplos e referências. O Kiro lê a descrição de cada skill e decide automaticamente quando ativá-la. Você não precisa chamar nada manualmente — basta pedir o que precisa.

## As 8 Skills do meu Setup

### 1. GSD (Get Shit Done)

A skill mais completa do meu arsenal. É um sistema de desenvolvimento orientado a specs com gerenciamento de contexto entre sessões. Resolve o problema clássico de "perder o fio da meada" em projetos longos.

O workflow é simples:
- `gsd:new-project` — inicializa o projeto com requisitos e roadmap
- `gsd:plan-phase N` — planeja uma fase com tarefas detalhadas
- `gsd:execute-phase N` — executa tarefa por tarefa
- `gsd:verify-work N` — valida com o usuário

Tudo fica em `.planning/` na raiz do projeto: estado, decisões, planos e resumos. Quando você abre uma sessão nova, o Kiro lê o `STATE.md` e sabe exatamente onde parou.

### 2. Systematic Debugging

Essa skill impõe uma regra de ferro: **nenhum fix sem investigação de root cause primeiro**. Parece óbvio, mas na pressão de um incidente, a tentação de "só tentar trocar isso aqui" é real.

O processo tem 4 fases:
1. **Investigação** — ler erros, reproduzir, checar mudanças recentes
2. **Análise de padrão** — comparar com código que funciona
3. **Hipótese e teste** — uma mudança por vez, método científico
4. **Implementação** — fix no root cause, não no sintoma

Se depois de 3 tentativas o fix não funcionar, a skill manda parar e questionar a arquitetura. Já me salvou de horas de thrashing.

### 3. MCP Builder

Guia para criar servidores MCP (Model Context Protocol) — o protocolo que permite ao Kiro se conectar com serviços externos via ferramentas customizadas. Uso bastante porque mantenho integrações com Zabbix e GLPI via MCP.

A skill cobre desde o planejamento da API até a criação de evaluations para testar se o LLM consegue usar as ferramentas corretamente. Recomenda TypeScript como stack principal, mas tem guia completo para Python também.

### 4. File Search

Busca inteligente em codebases usando duas ferramentas:
- **ripgrep (rg)** — busca textual ultrarrápida com regex
- **ast-grep (sg)** — busca estrutural que entende a sintaxe do código

A diferença é importante: `rg "function"` encontra a palavra "function" em qualquer lugar. `sg --pattern 'function $NAME($$$) { $$$ }' --lang js` encontra declarações de função reais, ignorando comentários e strings.

A skill ensina a estratégia certa: começar com buscas específicas, contar resultados antes de exibir, e refinar progressivamente.

### 5. Skill Creator

Meta-skill: serve para criar, testar e otimizar outras skills. Tem um workflow completo com evaluations, benchmark quantitativo e otimização de descrição para melhorar o triggering automático.

O loop é: escrever draft → rodar testes → revisar com o usuário → melhorar → repetir. Inclui até comparação cega entre versões para avaliar qual é melhor sem viés.

### 6. Claude API

Referência completa para desenvolver com a API do Claude e os SDKs da Anthropic. Cobre desde chamadas simples até agentes com ferramentas customizadas.

O que mais uso:
- Padrões de tool use para automações
- Streaming para interfaces interativas
- Batch processing para tarefas em volume

A skill detecta automaticamente a linguagem do projeto e carrega os exemplos corretos.

### 7. Internal Comms

Ajuda a escrever comunicações internas no formato que a empresa usa. Tem templates para:
- Updates 3P (Progress, Plans, Problems)
- Relatórios de incidente
- Status reports
- Newsletters internas

Como SRE, uso principalmente para post-mortems e comunicações de incidente. A skill garante que o formato e o tom estejam consistentes.

### 8. Webapp Testing

Toolkit para testar aplicações web com Playwright. Inclui um helper (`with_server.py`) que gerencia o ciclo de vida do servidor automaticamente.

O padrão que a skill ensina é "reconhecimento primeiro, ação depois":
1. Navegar e esperar o carregamento completo
2. Tirar screenshot ou inspecionar o DOM
3. Identificar seletores do estado renderizado
4. Executar ações com os seletores descobertos

Útil para validar deploys e testar funcionalidades de frontend sem sair do terminal.

## Como Instalar Skills

Skills são pastas com um `SKILL.md` dentro de `~/.kiro/skills/`:

```
~/.kiro/skills/
├── gsd/
│   └── SKILL.md
├── systematic-debugging/
│   └── SKILL.md
└── ...
```

Algumas skills vêm com recursos adicionais em subpastas como `references/`, `scripts/` e `assets/`. O Kiro carrega o `SKILL.md` quando a skill é ativada e lê os recursos adicionais sob demanda.

## Conclusão

O sistema de skills transforma o Kiro de um assistente genérico em uma ferramenta especializada. Cada skill adiciona conhecimento profundo sobre um domínio específico, e o triggering automático significa que você não precisa lembrar qual skill usar — basta trabalhar normalmente.

Se você está começando, recomendo instalar primeiro o **Systematic Debugging** e o **File Search**. São as mais universais e vão melhorar seu workflow imediatamente, independente do tipo de projeto.
