---
title: "Zabbix Templates e Discovery: Automatizando o Monitoramento"
date: 2026-06-19T08:00:00-03:00
description: |
  Adicionar hosts manualmente no Zabbix é toil. Discovery resolve isso.

  ⚡ Network Discovery: encontra hosts na rede automaticamente
  ⚡ Auto-registration: agent se registra sozinho
  ⚡ LLD: descobre filesystems, interfaces, containers dinamicamente

  Com discovery bem configurado, um novo servidor entra no monitoramento em minutos, sem intervenção manual.

  Seu Zabbix descobre hosts sozinho ou você ainda cadastra um por um?

  🔗 https://nerdseverino.com.br/blog/zabbix-templates-e-discovery/

  #Zabbix #Discovery #Templates #Monitoramento #SRE #Automação
categories:
  - SRE
  - Monitoramento
tags:
  - zabbix
  - templates
  - discovery
  - automação
  - serie-zabbix-na-pratica
keywords:
  - zabbix discovery
  - zabbix templates
  - lld zabbix
  - auto registration
autoThumbnailImage: false
thumbnailImagePosition: top
---

Cadastrar hosts manualmente no Zabbix é trabalho repetitivo que não agrega valor. Discovery e auto-registration eliminam esse toil e garantem que novos recursos entrem no monitoramento automaticamente.

<!--more-->

## Tipos de Discovery

### Network Discovery

O Zabbix varre ranges de IP procurando hosts:

```
Configuration → Discovery → Create discovery rule
  IP range: 10.0.0.0/24
  Checks: Zabbix agent, SNMP, ICMP ping
  Update interval: 1h
```

Ações automáticas quando descobrir:
- Adicionar host ao grupo correto
- Linkar template baseado no serviço detectado
- Habilitar host

### Auto-registration

O agent se registra sozinho no server. Ideal para ambientes cloud onde instâncias sobem e descem:

```
# No zabbix_agent2.conf da instância
Server=zabbix-server.internal
ServerActive=zabbix-server.internal
Hostname=web-api_i-0abc123_899360400100_us-east-1
HostMetadata=linux aws prod web
```

No Zabbix Server:
```
Configuration → Actions → Autoregistration actions
  Condition: Host metadata contains "linux aws prod"
  Operations:
    - Add to group: AWS/Produção/Web
    - Link template: Linux by Zabbix agent 2
    - Enable host
```

O `HostMetadata` é a chave. Use tags que identifiquem função, ambiente e plataforma.

### Low-Level Discovery (LLD)

Descobre recursos dinâmicos dentro de um host:

| LLD Rule | Descobre | Exemplo |
|----------|----------|---------|
| vfs.fs.discovery | Filesystems | /, /data, /var |
| net.if.discovery | Interfaces de rede | eth0, ens5 |
| docker.containers.discovery | Containers Docker | nginx, api, db |
| Custom | Qualquer coisa via script | Bancos, filas, endpoints |

LLD cria items, triggers e graphs automaticamente para cada recurso descoberto.

## Templates bem estruturados

### Hierarquia de templates

```
Template OS Linux (base)
  ├── Items: CPU, memória, disco, uptime, agent
  ├── Triggers: thresholds básicos
  └── LLD: filesystems, interfaces

Template App Nginx (serviço)
  ├── Items: connections, requests/s, status
  ├── Triggers: service down, high connections
  └── Web scenario: health check HTTP

Template AWS EC2 (plataforma)
  ├── Items: instance status, credit balance
  ├── Triggers: status check failed
  └── Macros: region, account
```

Host recebe: OS Linux + App Nginx + AWS EC2. Cada template cuida do seu domínio.

### Macros para flexibilidade

```
{$CPU_THRESHOLD} = 80        (padrão no template)
{$DISK_THRESHOLD} = 85       (padrão no template)
{$MEM_MIN_AVAILABLE} = 500M  (padrão no template)
```

Override por host quando necessário:
- Servidor de batch: `{$CPU_THRESHOLD}` = 95 (CPU alta é normal)
- Servidor de banco: `{$MEM_MIN_AVAILABLE}` = 2G (precisa de mais memória livre)

### Export e versionamento

```bash
# Exportar template via API
curl -s -X POST "https://zabbix.exemplo.com/api_jsonrpc.php" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "configuration.export",
    "params": {
      "format": "yaml",
      "options": {"templates": ["10001"]}
    },
    "auth": "token",
    "id": 1
  }' | jq -r '.result' > template_linux.yaml
```

Versione templates no Git. Quando precisar recriar o Zabbix, importa tudo.

## Dicas práticas

1. **HostMetadata padronizado**: Defina um padrão e documente. Ex: `{os} {cloud} {env} {role}`
2. **Discovery interval**: 1h para network, 10m para LLD
3. **Filtros no LLD**: Exclua filesystems temporários (tmpfs, devtmpfs)
4. **Template antes do host**: Nunca customize direto no host. Sempre no template.
5. **Teste em staging**: Valide templates em ambiente de teste antes de aplicar em produção

---

*Discovery bem configurado transforma o Zabbix de uma ferramenta manual em um sistema autônomo. Novos hosts entram no monitoramento sozinhos, recursos dinâmicos são descobertos automaticamente, e o time foca em análise ao invés de cadastro.*
