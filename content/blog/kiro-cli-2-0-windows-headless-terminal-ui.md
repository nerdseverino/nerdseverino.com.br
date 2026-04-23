---
title: "Kiro CLI 2.0: Windows, Headless Mode e a Nova Terminal UI"
date: 2026-04-23T08:00:00-03:00
description: |
  O Kiro CLI 2.0 chegou com 3 mudanças que mudam o jogo:

  🪟 Suporte nativo a Windows 11 (finalmente!)
  🤖 Headless mode para CI/CD (sem browser, sem interação)
  🖥️ Nova Terminal UI como padrão (syntax highlight, crew monitor, /spawn)

  A que mais me empolgou: subagents agora suportam dependências entre tarefas. Analisa o código primeiro, depois refatora, depois roda testes, tudo em paralelo quando possível.

  E o headless mode abre portas para automação que antes não existia: rodar Kiro em pipelines, cron jobs, scripts de deploy.

  Qual feature do 2.0 você mais quer testar?

  🔗 https://nerdseverino.com.br/blog/kiro-cli-2-0-windows-headless-terminal-ui/

  #KiroCLI #AI #DevTools #Windows #CICD #SRE
cover:
  image: "/images/uploads/cover-kiro-2.png"
  alt: "Cover"
  relative: false
categories:
  - DevOps
  - Ferramentas
tags:
  - serie-kiro-cli
  - kiro
  - cli
  - ia
  - windows
  - automação
keywords:
  - kiro cli 2.0
  - kiro windows
  - headless mode
  - terminal ui
  - subagents
autoThumbnailImage: false
thumbnailImagePosition: top
---

O Kiro CLI 2.0 saiu em abril de 2026 com três mudanças significativas: suporte nativo a Windows, modo headless para automação, e uma nova interface de terminal que virou padrão. Para quem usa o Kiro no dia a dia, cada uma dessas features resolve uma dor real.

<!--more-->

## Windows: finalmente

Até a versão 1.x, o Kiro CLI rodava apenas em macOS e Linux. Quem usava Windows precisava de WSL, o que funcionava mas adicionava uma camada de complexidade.

A versão 2.0 roda nativamente no Windows 11. Instalação via PowerShell, auto-update em background, e todas as features disponíveis: Terminal UI, headless mode, custom agents, MCP servers.

Para quem trabalha em ambientes mistos (servidor Linux, desktop Windows), isso elimina a fricção de ter que abrir WSL só para usar o Kiro.

## Headless Mode: Kiro sem browser

Essa é a feature que abre mais possibilidades. O headless mode permite rodar o Kiro sem interação, sem browser, sem terminal interativo.

```bash
# Autenticar com API key
export KIRO_API_KEY="sua-chave"

# Executar prompt direto
kiro-cli --no-interactive "Analise os logs do último deploy e identifique erros"

# Confiar em todas as ferramentas (sem confirmação)
kiro-cli --no-interactive --trust-all-tools "Rode os testes e corrija os que falharem"

# Confiar em ferramentas específicas
kiro-cli --no-interactive --trust-tools "execute_bash,fs_read" "Liste os arquivos modificados hoje"
```

### Casos de uso práticos

**CI/CD Pipeline**: Adicionar o Kiro como step no GitHub Actions para revisar código, gerar changelog, ou validar configurações antes do deploy.

**Cron jobs**: Agendar análises periódicas. Por exemplo, rodar toda segunda de manhã: "Analise os custos AWS da semana passada e envie resumo no Telegram".

**Scripts de deploy**: Integrar o Kiro no processo de deploy para validar configurações, verificar dependências, ou gerar documentação automaticamente.

**Monitoramento**: Usar o Kiro para analisar alertas e sugerir ações. Quando um alarme dispara, um script chama o Kiro com o contexto do alarme e ele retorna um diagnóstico.

A API key está disponível para assinantes Pro, Pro+ e Power. Administradores enterprise podem controlar a geração de chaves via governance settings.

## Terminal UI: a nova interface padrão

A Terminal UI que era experimental na 1.28 virou padrão na 2.0. A diferença é visível:

### O que mudou

- **Markdown renderizado**: Respostas com syntax highlight, tabelas formatadas, headers coloridos
- **Barra de status**: Mostra modelo ativo, tokens usados, status do agente
- **Crew Monitor** (`Ctrl+G`): Acompanha subagents em tempo real, vê o que cada um está fazendo
- **Painéis interativos**: Navegar contexto, sessões e ferramentas sem sair do terminal

### Novos comandos

| Comando | Função |
|---------|--------|
| `/spawn` | Iniciar sessões paralelas de agentes |
| `/chat new` | Nova conversa sem reiniciar o CLI |
| `/theme` | Customizar cores da interface |
| `/copy` | Copiar para clipboard (funciona via SSH) |
| `/transcript` | Revisar histórico no pager |
| `/guide` | Trocar para o agente de onboarding |
| `Ctrl+G` | Abrir crew monitor |

### Voltar para a interface clássica

Se preferir a interface antiga:

```bash
# Flag na execução
kiro-cli --classic

# Ou configurar permanentemente
kiro-cli settings chat.ui "classic"
```

## Subagents com dependências

A melhoria mais técnica da 2.0: subagents agora suportam dependências entre tarefas.

Antes, subagents rodavam em paralelo mas sem coordenação. Agora você pode definir uma cadeia:

1. Analisa o codebase (subagent A)
2. Refatora os módulos identificados (subagent B, depende de A)
3. Roda os testes (subagent C, depende de B)

Steps independentes rodam em paralelo, steps dependentes esperam o anterior terminar. O crew monitor (`Ctrl+G`) mostra o progresso de cada um em tempo real.

## Novos modelos

A 2.0 também trouxe acesso a novos modelos:

| Modelo | Contexto | Multiplicador | Destaque |
|--------|----------|---------------|----------|
| Claude Opus 4.7 | 1M tokens | 2.2x | Melhor performance agentic |
| Claude Sonnet 4.6 | 1M tokens | 1x | Uso geral, agora GA |
| GLM-5 | 200K tokens | 0.5x | Barato, bom para refactoring |
| MiniMax M2.5 | 200K tokens | 0.25x | Mais barato, open weight |

O contexto de 1M tokens no Opus e Sonnet é significativo para quem trabalha com codebases grandes. Dá para carregar um repositório inteiro no contexto.

## Como atualizar

```bash
# Linux/macOS: auto-update ou
curl -fsSL https://kiro.dev/install.sh | bash

# Windows (PowerShell)
irm https://kiro.dev/install.ps1 | iex

# Verificar versão
kiro-cli --version
```

## Vale a pena atualizar?

Se você usa o Kiro CLI regularmente:

- **Windows user**: Atualização obrigatória, sai do WSL
- **CI/CD**: Headless mode é game changer para automação
- **Power user**: Terminal UI e crew monitor melhoram muito a experiência
- **Orçamento apertado**: GLM-5 e MiniMax M2.5 com multiplicadores baixos

Se você usa casualmente, a Terminal UI sozinha já justifica. A renderização de markdown e o syntax highlight fazem diferença na legibilidade das respostas.

---

*O Kiro CLI 2.0 não é só uma atualização incremental. Windows support democratiza o acesso, headless mode abre automação, e a Terminal UI melhora o dia a dia. Se você ainda está na 1.x, vale atualizar.*
