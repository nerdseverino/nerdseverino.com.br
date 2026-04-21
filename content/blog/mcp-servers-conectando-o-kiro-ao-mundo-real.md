---
title: "MCP Servers: Conectando o Kiro ao Mundo Real"
date: 2026-05-01T08:00:00-03:00
description: |
  O Kiro CLI sozinho é poderoso. Conectado a sistemas externos, é transformador.

  MCP (Model Context Protocol) permite que o Kiro interaja com qualquer serviço via ferramentas customizadas:

  🔧 GLPI: criar e gerenciar chamados por conversa
  📊 Zabbix: consultar hosts, problemas e métricas
  💬 WhatsApp: ler e enviar mensagens de grupos
  ☁️ AWS: gerenciar infraestrutura direto do terminal

  O melhor: você pode criar seus próprios MCP servers em Python ou TypeScript.

  Quais sistemas você conectaria ao seu assistente AI?

  🔗 https://nerdseverino.com.br/blog/mcp-servers-conectando-o-kiro-ao-mundo-real/

  #KiroCLI #MCP #AI #DevTools #Automação #SRE
coverImage: /images/uploads/cover-mcp-servers.png
categories:
  - DevOps
  - Ferramentas
tags:
  - serie-kiro-cli
  - kiro
  - mcp
  - ia
  - automação
  - integração
keywords:
  - mcp servers
  - model context protocol
  - kiro cli
  - integração ia
coverImage: /images/uploads/cover-mcp-servers.png
autoThumbnailImage: false
coverImage: /images/uploads/cover-mcp-servers.png
thumbnailImagePosition: top
---

O Kiro CLI é poderoso para trabalhar com arquivos, código e terminal. Mas o dia a dia de um SRE envolve muito mais: chamados, monitoramento, mensagens, infraestrutura cloud. O MCP (Model Context Protocol) é o que conecta o Kiro a tudo isso.

<!--more-->

## O que é MCP

MCP é um protocolo aberto que padroniza como aplicações fornecem contexto e ferramentas para LLMs. Na prática, um MCP server é um processo local que expõe ferramentas que o Kiro pode chamar.

Quando você pergunta "quais alarmes estão ativos no Zabbix?", o Kiro não adivinha. Ele chama a ferramenta `problem_get` do MCP server do Zabbix, que faz a query real na API e retorna os dados.

## MCP Servers que uso no dia a dia

### GLPI (Chamados)

Gerencio chamados de suporte sem sair do terminal:

```
"lista meus chamados abertos"
→ Kiro chama list_my_tickets do MCP GLPI
→ Retorna tabela com ID, título, prioridade, status

"adiciona uma nota no chamado 2026030108: diagnóstico concluído, causa raiz identificada"
→ Kiro chama add_followup com ticket_id e conteúdo

"cria uma tarefa de 2h no chamado 456"
→ Kiro chama create_task com horas e descrição
```

### Zabbix (Monitoramento)

Consulto hosts, problemas e métricas:

```
"quais problemas estão ativos agora?"
→ problem_get com filtro de severidade

"qual o status do host servidor-web-01?"
→ host_get com busca por nome

"coloca o host X em manutenção por 2 horas"
→ maintenance_create com período e hostid
```

### WhatsApp

Leio mensagens de grupos de operação e envio notificações:

```
"o que falaram no grupo de operações nas últimas 2 horas?"
→ whatsapp_read_messages com group_id e hours

"manda no grupo: deploy do serviço X concluído"
→ whatsapp_send_message com to e message
```

### AWS (via MCP nativo)

O Kiro já vem com ferramentas AWS integradas:

```
"quais alarmes estão em ALARM no CloudWatch?"
→ get_active_alarms

"qual o custo AWS do mês passado por serviço?"
→ get_cost_and_usage com granularidade mensal

"lista as instâncias EC2 na conta X"
→ use_aws com ec2 describe-instances
```

## Configurando MCP Servers

Os MCP servers são configurados em `~/.kiro/settings/mcp.json`:

```json
{
  "mcpServers": {
    "glpi": {
      "command": "python3",
      "args": ["/caminho/para/glpi_mcp_server.py"],
      "env": {
        "GLPI_URL": "https://glpi.exemplo.com",
        "GLPI_TOKEN": "seu-token"
      }
    },
    "zabbix": {
      "command": "python3",
      "args": ["/caminho/para/zabbix_mcp_server.py"],
      "env": {
        "ZABBIX_URL": "https://zabbix.exemplo.com",
        "ZABBIX_TOKEN": "seu-token"
      }
    }
  }
}
```

Cada server é um processo independente. O Kiro inicia todos ao abrir uma sessão e se comunica via stdin/stdout.

## Criando seu próprio MCP Server

Com Python e FastMCP, criar um MCP server é surpreendentemente simples:

```python
from fastmcp import FastMCP

mcp = FastMCP("meu-server")

@mcp.tool()
def verificar_status(servico: str) -> str:
    """Verifica o status de um serviço."""
    # Sua lógica aqui
    import subprocess
    result = subprocess.run(
        ["systemctl", "is-active", servico],
        capture_output=True, text=True
    )
    return f"{servico}: {result.stdout.strip()}"

@mcp.tool()
def listar_containers() -> str:
    """Lista containers Docker rodando."""
    import subprocess
    result = subprocess.run(
        ["docker", "ps", "--format", "table {{.Names}}\t{{.Status}}"],
        capture_output=True, text=True
    )
    return result.stdout

if __name__ == "__main__":
    mcp.run()
```

Registre no `mcp.json` e o Kiro já consegue usar:

```
"quais containers estão rodando?"
→ Kiro chama listar_containers do seu MCP server
```

## Dicas práticas

**Credenciais**: Use variáveis de ambiente no `env` do `mcp.json`, nunca hardcode tokens no código.

**Timeout**: MCP servers que fazem chamadas de rede podem demorar. Implemente timeouts nas suas ferramentas.

**Logs**: Adicione logging no server para debugar quando uma ferramenta não retorna o esperado.

**Escopo**: Cada server deve ter um propósito claro. Não crie um server gigante com 50 ferramentas. Separe por domínio (GLPI, Zabbix, AWS).

**Teste local**: Antes de registrar no Kiro, teste o server isolado para garantir que as ferramentas funcionam.

## O impacto no workflow

Antes do MCP, meu fluxo era:
1. Abrir terminal → rodar comando
2. Abrir browser → acessar GLPI → criar nota
3. Abrir outro tab → acessar Zabbix → verificar alarme
4. Abrir WhatsApp → informar o time

Com MCP, tudo acontece em uma conversa:
1. "Verifica os alarmes do Zabbix, cria uma nota no chamado 123 com o diagnóstico, e avisa no grupo de operações"

Uma frase, três sistemas, zero troca de contexto.

---

*MCP transforma o Kiro de um assistente de terminal em um hub de operações. Se você opera múltiplos sistemas no dia a dia, conectar eles ao Kiro via MCP é o investimento com maior retorno de produtividade que você pode fazer.*
