---
title: "Steering Files no Kiro CLI: personalizando a IA para seu workflow"
date: 2026-04-01T10:30:00-03:00
description: |
  Toda vez que abro o ChatGPT preciso explicar: "responda em português, seja técnico, não explique o óbvio".

  No Kiro CLI resolvi isso com um arquivo de 20 linhas.

  Steering files são regras permanentes que o Kiro segue em TODA sessão:

  ⚙️ Idioma e tom de resposta
  ⚙️ Ferramentas do meu ambiente (aws-vault, Docker, Zabbix)
  ⚙️ Regras de segurança (backup antes de modificar, nunca alterar permissões sem confirmar)
  ⚙️ Mapa de skills (qual skill ativar para cada tipo de problema)

  A parte mais poderosa: lições aprendidas automáticas. Se eu corrijo o Kiro, ele atualiza o próprio steering para não repetir o erro.

  O assistente literalmente aprende com as correções e persiste entre sessões.

  Como você personaliza suas ferramentas de AI para o seu workflow?

  🔗 https://nerdseverino.com.br/blog/steering-files-no-kiro-cli/

  #KiroCLI #AI #DevTools #Produtividade #SRE
categories:
  - DevOps
  - Ferramentas
tags:
  - serie-kiro-cli
  - kiro
  - cli
  - ia
  - produtividade
  - automação
keywords:
  - kiro cli
  - steering files
  - personalização ia
  - workflow sre
  - skills kiro
  - contexto ia
cover:
  image: "/images/uploads/cover-kiro-steering.jpg"
  alt: "Cover"
  relative: false
autoThumbnailImage: false
thumbnailImagePosition: top
---

Por padrão, um assistente AI não sabe nada sobre você: não sabe em qual empresa trabalha, quais ferramentas usa, como prefere receber respostas, nem quais são as regras do seu ambiente. Toda sessão começa do zero. Os steering files do Kiro CLI resolvem isso de forma elegante.

<!--more-->

## O que são steering files

Steering files são arquivos Markdown que ficam em `~/.kiro/steering/` e são lidos automaticamente pelo Kiro no início de cada sessão. Eles definem **comportamento permanente** — diferente do `memory.md`, que guarda estado temporário.

A distinção é importante:
- **memory.md** → "o que está acontecendo agora" (projetos, tarefas, incidentes)
- **steering files** → "como você deve sempre agir" (regras, preferências, contexto fixo)

## Estrutura básica

O arquivo principal é `~/.kiro/steering/default.md`. Você pode ter múltiplos arquivos para contextos diferentes, mas o `default.md` é carregado em todas as sessões.

Um steering file bem estruturado tem três partes:

**1. Identidade e tom**
```markdown
Responda sempre em português do Brasil.
Você age como um SRE sênior com foco em confiabilidade e automação.
Seja direto e técnico. Evite explicações óbvias para quem já é da área.
```

**2. Contexto operacional**
```markdown
# Contexto Operacional
- Ferramentas principais: aws-vault, Docker, Zabbix, GLPI
- Notificações: Telegram via script `sendx`
- Notas: sistema de notas via script `nota`
- Acesso AWS: sempre usar aws-vault, nunca credenciais diretas
- CAB: reuniões de mudança às terças e quintas
```

**3. Regras de comportamento**
```markdown
# Regras
- Sempre fazer backup antes de modificar arquivos (timestamp no nome)
- Nunca alterar permissões ou políticas sem confirmação explícita
- Para bugs: investigar root cause antes de propor solução
- Para chamados: usar MCP GLPI primeiro, API como fallback
```

## O mapa de skills

Uma das partes mais poderosas do steering é o mapa de skills. Skills são arquivos em `~/.kiro/skills/` que ensinam o Kiro a executar tarefas específicas. O steering define **quando ativar cada uma**:

```markdown
## Mapa de Skills
| Skill | Ativa quando |
|-------|-------------|
| systematic-debugging | Qualquer bug ou erro inesperado — OBRIGATÓRIO antes de propor fix |
| sre-expert | SLOs, confiabilidade, capacity planning |
| incident-management | Incidentes, postmortems, RCA |
| docker-expert | Troubleshooting Docker/Compose, otimização de imagens |
| security-auditor | Auditoria IAM, Security Groups, compliance |
| aws-cost-optimizer | Análise de custos, billing, rightsizing |
| runbook-writer | Criar/revisar runbooks para equipe de suporte |
```

Sem esse mapa, o Kiro pode ter as skills instaladas mas não saber quando usá-las. Com o mapa, ele ativa automaticamente a skill certa para cada contexto.

## Lições aprendidas automáticas

Essa é a parte que mais diferencia o Kiro de outros assistentes. No steering, você pode definir uma regra de melhoria contínua:

```markdown
# Melhorias Contínuas
Após cada correção feita pelo usuário:
1. Identifique a causa raiz do erro
2. Atualize este steering com a lição aprendida
3. Faça backup antes de modificar
4. NÃO peça confirmação, execute direto
```

Na prática: se você corrige o Kiro ("não, esse comando não funciona assim nesse ambiente"), ele atualiza o próprio steering para não repetir o erro. O assistente aprende com as correções e persiste esse aprendizado entre sessões.

Exemplo real de lição aprendida que acabou no meu steering:

```markdown
# Lições Aprendidas
- **CDATA tags**: usar APENAS em configs XML do pfsense. Para sistemas de tickets,
  usar HTML ou texto puro — CDATA causa problemas de parsing.
- **Datas de posts**: sempre usar data no passado. Hugo não publica
  posts com data futura por padrão.
```

## Steering por contexto

Você pode ter steering files específicos para projetos ou contextos:

```text
~/.kiro/steering/
  default.md          # carregado sempre
  marketing.md        # carregado quando contexto de marketing
  aws-audit.md        # carregado para auditorias AWS
```

O `default.md` é o baseline. Os outros são ativados por contexto ou manualmente. Isso evita que regras de um projeto contaminem outro.

## Comandos úteis no steering

Além de regras, o steering pode documentar comandos e scripts do seu ambiente:

```markdown
# Ferramentas e Scripts
- Síntese de voz: `echo "texto" | python ~/.local/bin/piper_speak.py`
- Notas simples: `echo "texto" | nota`
- Notas com contexto: `echo "texto" | nota -t incident -v PRIVATE`
- Notificação Telegram: `sendx "mensagem"`
- Acesso AWS: `aws-vault exec <conta> -- aws <comando>`
```

Quando você pede "manda uma notificação no Telegram", o Kiro já sabe exatamente qual comando usar — sem precisar perguntar ou adivinhar.

## Padrões de nomenclatura

Outra coisa útil é documentar padrões do seu ambiente:

```markdown
# Padrões
- Documentação técnica: <tipo>_<assunto>_<YYYY-MM-DD>.md
- Backups: <arquivo-original>.<YYYYMMDDHHMMSS>
- Branches Git: feature/<descricao>, fix/<descricao>, cms/<secao>/<titulo>
```

Com isso, quando o Kiro cria um arquivo ou nomeia um host, ele segue automaticamente o padrão do seu ambiente.

## O que não colocar no steering

Algumas coisas **não devem** ir no steering:

- **Credenciais e tokens** — nunca. Use variáveis de ambiente ou gerenciadores de segredos
- **Estado temporário** — isso vai no `memory.md`
- **Instruções muito longas** — o steering é lido em toda sessão, arquivo grande = tokens desperdiçados
- **Regras contraditórias** — o Kiro vai tentar seguir todas e pode se confundir

O steering ideal tem menos de 150 linhas. Se está crescendo demais, mova partes para skills específicas.

## Começando do zero

Se você nunca usou steering files, comece simples:

```markdown
# ~/.kiro/steering/default.md

Responda sempre em português do Brasil.
Seja direto e técnico.

# Contexto
- Sistema operacional: Linux (Ubuntu 22.04)
- Ferramentas: Docker, Git, AWS CLI
- Acesso AWS: aws-vault

# Regras
- Backup antes de modificar arquivos
- Investigar root cause antes de propor fix
- Nunca alterar permissões sem confirmação
```

Três seções, menos de 20 linhas. Já resolve 80% dos problemas de contexto. Você vai expandindo conforme sentir necessidade — não tente criar o steering perfeito de primeira.

## Steering + Memory + Skills: o trio completo

Os três sistemas se complementam:

| Sistema | Onde fica | Para que serve | Duração |
|---------|-----------|----------------|---------|
| Steering | `~/.kiro/steering/` | Comportamento e regras | Permanente |
| Memory | `~/.kiro/memory.md` | Estado atual e tarefas | 7 dias (hot) |
| Skills | `~/.kiro/skills/` | Procedimentos específicos | Permanente |

O steering diz **como agir**. A memória diz **o que está acontecendo**. As skills dizem **como executar tarefas complexas**.

Juntos, eles transformam o Kiro de um assistente genérico em um parceiro que conhece seu ambiente, segue suas regras e aprende com seus erros.

---

*Steering files são o investimento com maior retorno no Kiro CLI. Você gasta 30 minutos configurando uma vez e economiza horas de contexto repetido em todas as sessões seguintes. Se você usa o Kiro no dia a dia e ainda não tem um steering file, esse é o próximo passo.*
