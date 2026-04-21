---
title: "Memória Persistente no Kiro CLI: Contexto que Sobrevive Entre Sessões"
date: 2026-03-30T16:30:00-03:00
description: |
  O maior problema de assistentes AI no terminal: cada sessão começa do zero.

  Você explica o contexto, trabalha por 1 hora, fecha o terminal. Na próxima vez? Explica tudo de novo.

  Resolvi com um sistema de memória em duas camadas:

  🧠 Hot Memory → arquivo local com contexto dos últimos 7 dias
  📦 Cold Memory → arquivo permanente no Obsidian para busca futura
  📋 Runbook Pessoal → soluções de problemas que o Kiro lembra por mim

  Agora quando abro o Kiro, ele já sabe quais projetos estou tocando, quais tarefas estão pendentes e soluções de problemas anteriores.

  Assistente AI sem memória é como um colega brilhante com amnésia.

  Você usa algum sistema para manter contexto entre sessões de AI?

  🔗 https://nerdseverino.com.br/blog/memoria-persistente-no-kiro-cli/

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
  - memória persistente
  - contexto ia
  - knowledge base
  - assistente terminal
  - sre
autoThumbnailImage: false
thumbnailImagePosition: top
---

O maior problema de assistentes AI no terminal é que cada sessão começa do zero. Você explica o contexto, trabalha por uma hora, fecha o terminal — e na próxima vez precisa explicar tudo de novo. Resolvi isso no Kiro CLI com um sistema de memória em duas camadas que mantém contexto entre sessões.

<!--more-->

## O problema real

Como SRE, eu lido com dezenas de projetos simultâneos: tickets de clientes, incidentes, deploys, monitoramento. Quando abro o Kiro para continuar um troubleshooting do dia anterior, ele não sabe:

- Qual conta AWS eu estava investigando
- Que comandos já rodei
- Qual foi a hipótese que descartei
- Quais tarefas estão pendentes

Repetir esse contexto toda sessão é perda de tempo. E pior: informação se perde.

## A arquitetura: Hot + Cold

A solução que implementei usa duas camadas:

**Hot Memory** (`~/.kiro/memory.md`) — Contexto ativo dos últimos 7 dias. Lido automaticamente no início de cada sessão. Contém:
- Projetos ativos e status
- Tarefas pendentes com prioridade
- Notas rápidas com TTL
- Referências técnicas (IPs, servidores, endpoints)
- Histórico das últimas sessões
- Runbook pessoal (soluções de problemas recorrentes)

**Cold Memory** (Obsidian ou qualquer app de notas) — Arquivo permanente. Sessões com mais de 7 dias são compactadas e movidas para uma pasta de arquivo no Obsidian, com tags como `#kiro` e `#memoria`. Isso mantém tudo buscável e organizado sem poluir o contexto ativo.

A ideia é simples: o que é recente fica no arquivo local (rápido de ler), o que é antigo vai para o vault de notas (buscável mas não polui o contexto). Se você usa Obsidian, basta criar uma pasta `Kiro/Arquivo/` e mover as sessões antigas para lá. O graph view do Obsidian ainda conecta tudo pelas tags.

## O arquivo memory.md

O coração do sistema é um Markdown estruturado:

```markdown
# Kiro Memory - Memória Persistente de Sessões
> Última atualização: 2026-03-30 13:30

## Contexto do Usuário
- Nome: nerdseverino
- Perfil: SRE Sênior
- Ferramentas: aws-vault, Docker, Zabbix, GLPI

## Referência Rápida
### Servidores
- monitoring-server: i-0abc123def456789 (us-east-1)
- dns-local: nerdseverino@10.0.0.50

## Projetos Ativos
- 🔴 Cliente ABC VPN: Bug kernel pfSense [GLPI#123]
- 🟡 Zabbix Remediation: Phase 1C pendente
- 🟢 Blog pessoal: CI/CD funcionando

## Tarefas Pendentes
### 🔴 P1 — Urgente
- Corrigir integração SNS/SES [GLPI#456]
### 🟡 P2 — Importante
- Criar runbooks Tier 1
### 🟢 P3 — Quando possível
- Avaliar upgrade proxy Zabbix

## Notas Rápidas
- **2026-03-30** [perm]: SNS + KMS — chave managed bloqueia service principals
- **2026-03-26** [30d]: Lembrar de criar IAM Role na conta sandbox

## Runbook Pessoal
| Problema | Solução | Data |
|----------|---------|------|
| pfSense não encaminha VPN | Bug kernel FreeBSD — ip_forward(). Atualizar versão. | 2026-03 |
| API notas "user not found" | Token JWT antigo no .bashrc sobrescrevia PAT | 2026-03 |

## Histórico de Sessões Recentes
| Data | Tags | Resumo |
|------|------|--------|
| 2026-03-30 | [cliente] [ses] [sns] | Diagnóstico SNS/SES... |
```

Quando o Kiro inicia uma sessão, ele lê esse arquivo e já sabe quem eu sou, o que estou fazendo e o que está pendente.

## Os comandos

Criei uma skill (`kiro-memory`) que responde a comandos em linguagem natural:

### "salva memória"

Atualiza o `memory.md` com o resumo da sessão atual, move sessões antigas para o Obsidian e limpa o que expirou:

1. Faz backup do arquivo atual
2. Adiciona resumo da sessão no histórico
3. Sessões com mais de 7 dias → agrupa e move para `Kiro/Arquivo/` no Obsidian
4. Remove tarefas concluídas e notas expiradas
5. Atualiza a knowledge base do Kiro

Tudo automático, sem pedir confirmação.

### "tarefa concluída: descrição"

Move a tarefa de "Pendentes" para "Concluídas" com data. Na próxima vez que salvar memória, ela é arquivada no Obsidian e removida do arquivo local.

### "lembra disso: informação"

Adiciona uma nota rápida com TTL de 30 dias. Se for um IP, servidor ou solução de problema, ele classifica automaticamente:

- IP/servidor → vai para "Referência Rápida"
- Solução de problema → vai para "Runbook Pessoal"
- Resto → vai para "Notas Rápidas" com TTL

### "o que fizemos sobre X?"

Busca no hot memory (recente) e no cold memory (Obsidian) e retorna um resumo consolidado indicando a fonte.

### "revisão semanal"

Lista tarefas por prioridade, destaca as paradas há mais de 7 dias e sugere ações: arquivar projetos encerrados, escalar tarefas travadas, repriorizar.

## O Runbook Pessoal

Essa é a parte que mais me economiza tempo. Toda vez que resolvo um problema não trivial, o Kiro adiciona no runbook:

```
| Problema | Solução | Data |
|----------|---------|------|
| Proxy Zabbix offline | Verificar EC2 + SSM. docker-compose pull/down/up. Checar IP público. | 2026-03 |
| Inodes /home lotando | Script cleanup: limpa cache UV, journald, pip, npm | 2026-03 |
```

Quando o mesmo problema aparece meses depois, o Kiro já sabe a solução. Não preciso lembrar, não preciso pesquisar de novo.

## Knowledge Bases

Além do `memory.md`, o Kiro tem knowledge bases indexadas que permitem busca semântica. Eu indexei:

- Documentação do GLPI
- Manual do Steampipe AWS
- Documentação do Zabbix
- Contexto SSH dos servidores

Quando pergunto algo sobre Zabbix, o Kiro busca na knowledge base antes de responder. Não é um RAG genérico — é a **minha** documentação, indexada localmente.

## O steering file

O `memory.md` guarda estado. O steering file (`~/.kiro/steering/default.md`) guarda **comportamento**. É onde defino:

- Responder sempre em português
- Fazer backup antes de modificar arquivos
- Usar aws-vault para acessar AWS
- Nunca mudar permissões sem perguntar
- Formato de daily report
- Mapa de skills (quando usar cada uma)

A diferença é sutil mas importante: memória é "o que está acontecendo", steering é "como você deve agir".

## Lições aprendidas

Depois de algumas semanas usando esse sistema:

**O que funciona:**
- TTL nas notas evita acúmulo de lixo
- Prioridade nas tarefas (🔴🟡🟢) facilita a revisão semanal
- Runbook pessoal é absurdamente útil para problemas recorrentes
- Arquivamento automático no Obsidian mantém o arquivo local enxuto

**O que não funciona:**
- Se o arquivo fica grande demais (>500 linhas), o Kiro gasta tokens lendo contexto irrelevante
- Precisa disciplina para rodar "salva memória" no final da sessão
- Cold memory depende de manter o vault do Obsidian acessível — se usar sync (iCloud, Syncthing, Git), funciona em qualquer máquina

**Melhorias futuras:**
- Automatizar o "salva memória" no encerramento da sessão
- Adicionar métricas (quantas tarefas concluídas por semana)
- Integrar com GLPI para sincronizar tarefas automaticamente

## Como implementar

Se quiser replicar:

1. Crie `~/.kiro/memory.md` com a estrutura básica (contexto, projetos, tarefas, histórico)
2. Crie uma skill em `~/.kiro/skills/kiro-memory/SKILL.md` com os comandos e triggers
3. Adicione no steering: "No início de cada sessão, leia ~/.kiro/memory.md"
4. Para cold memory, qualquer sistema de notas serve (Obsidian, Notion, Logseq, até uma pasta de arquivos Markdown)

O importante não é a ferramenta, é o hábito: no final de cada sessão, salvar o contexto. No início da próxima, recuperar.

---

*Assistentes AI são poderosos, mas sem memória são como um colega brilhante que tem amnésia. Dar memória ao Kiro transformou ele de "ferramenta que uso" para "parceiro que sabe o que estou fazendo". Se você usa o Kiro CLI no dia a dia, implementar isso vai mudar seu workflow.*
