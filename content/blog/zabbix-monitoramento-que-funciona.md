---
title: "Zabbix para SREs: Monitoramento que Funciona de Verdade"
date: 2026-06-17T08:00:00-03:00
description: |
  Ter Zabbix instalado não é ter monitoramento. É ter uma ferramenta.

  Monitoramento que funciona de verdade:
  ⚡ Alerta o que importa (não tudo que se move)
  ⚡ Tem contexto (não só "CPU alta")
  ⚡ Gera ação (não só notificação)
  ⚡ É mantido (templates atualizados, hosts limpos)

  Depois de operar Zabbix com 200+ hosts e 80+ contas AWS, aprendi que menos é mais.

  Quantos alertas do seu Zabbix você realmente olha?

  🔗 https://nerdseverino.com.br/blog/zabbix-monitoramento-que-funciona/

  #Zabbix #Monitoramento #SRE #Observabilidade #DevOps
categories:
  - SRE
  - Monitoramento
tags:
  - zabbix
  - monitoramento
  - sre
  - observabilidade
  - serie-zabbix-na-pratica
keywords:
  - zabbix monitoramento
  - zabbix sre
  - monitoramento produção
autoThumbnailImage: false
thumbnailImagePosition: top
---

Zabbix instalado com templates padrão e 500 triggers ativas não é monitoramento. É ruído. Monitoramento que funciona é aquele que te acorda quando precisa e te deixa dormir quando não precisa.

<!--more-->

## O problema do monitoramento padrão

Cenário comum: instala Zabbix, adiciona hosts com template "Linux by Zabbix agent", habilita tudo. Resultado:

- 200 items por host
- 50 triggers por host
- 10.000 items no total
- 2.500 triggers
- 90% nunca geram ação útil

O time começa a ignorar alertas. Quando um alerta real aparece, ninguém percebe.

## Filosofia: menos é mais

### O que monitorar

| Prioridade | O que | Por que |
|-----------|-------|---------|
| Alta | Disponibilidade (serviço responde?) | Impacto direto no usuário |
| Alta | Disco (>85%) | Causa mais comum de parada |
| Alta | Certificado SSL (expira em <15 dias) | Prevenção |
| Média | CPU sustentada (>80% por 15 min) | Pode indicar problema |
| Média | Memória (>85%) | Risco de OOM |
| Média | Conexões de banco | Leak de conexão |
| Baixa | Uptime | Informativo |
| Baixa | Network throughput | Baseline |

### O que NÃO monitorar (ou monitorar sem alertar)

- CPU spikes curtos (normal em deploys, cron jobs)
- Memória cache (Linux usa cache, não é problema)
- Disk I/O sem contexto (alto I/O pode ser normal)
- Processos específicos (a menos que seja crítico)

## Organização de hosts

### Naming convention

```
<nome>_<instance-id>_<account-id>_<região>
```

Exemplo: `web-api_i-0abc123_899360400100_us-east-1`

Parece verboso, mas quando você tem 200 hosts de 20 contas diferentes, saber de qual conta e região é o host sem precisar abrir nada é essencial.

### Host groups por função

```
AWS/Produção/Web
AWS/Produção/Database
AWS/Produção/Cache
AWS/Staging
AWS/Shared Services
```

Não agrupe por cliente no Zabbix. Agrupe por função. Isso facilita templates e dashboards.

## Templates: a base de tudo

### Princípios

1. **Um template por função**, não por host
2. **Herança**: Template base (OS) + Template de serviço (nginx, mysql)
3. **Macros para thresholds**: `{$CPU_THRESHOLD}` ao invés de valor fixo
4. **Desabilitar items desnecessários**: Não precisa de 200 items por host

### Template base Linux (mínimo)

Items essenciais:

| Item | Key | Intervalo |
|------|-----|-----------|
| CPU utilization | system.cpu.util | 1m |
| Memory available | vm.memory.size[available] | 1m |
| Disk space / | vfs.fs.size[/,pused] | 5m |
| System uptime | system.uptime | 5m |
| Agent ping | agent.ping | 1m |

Triggers essenciais:

| Trigger | Severidade | Expressão |
|---------|-----------|-----------|
| Agent unreachable | High | nodata(agent.ping, 5m) |
| Disk space critical | High | vfs.fs.size > {$DISK_THRESHOLD:95} |
| Disk space warning | Warning | vfs.fs.size > {$DISK_THRESHOLD:85} |
| High CPU | Warning | avg(system.cpu.util, 15m) > {$CPU_THRESHOLD:80} |
| Low memory | Warning | vm.memory.size[available] < {$MEM_THRESHOLD:500M} |

5 items, 5 triggers. Cobre 80% dos problemas reais.

## Manutenção do Zabbix

### Revisão mensal

- Hosts desabilitados há mais de 30 dias → remover
- Items "not supported" → corrigir ou desabilitar
- Triggers que nunca dispararam em 90 dias → avaliar necessidade
- Templates não utilizados → remover

### Higiene de dados

```
# Verificar items not supported
Monitoring → Latest data → Filter: State = Not supported

# Verificar hosts sem dados
Reports → Availability report → Filter: Availability < 50%
```

## Integração com operação

Zabbix sozinho não resolve. Precisa estar integrado:

- **Alertas → Telegram/Slack**: Notificação imediata
- **Alertas → GLPI**: Abertura automática de chamado
- **Dashboards → TV na operação**: Visibilidade constante
- **API → Scripts**: Automação de tarefas repetitivas

## Checklist de saúde do Zabbix

- [ ] Menos de 50 triggers por host (média)
- [ ] Zero items "not supported" ativos
- [ ] Alertas com ação definida (não só notificação)
- [ ] Macros para thresholds (não valores fixos)
- [ ] Hosts sem dados há 30+ dias removidos
- [ ] Templates organizados por função
- [ ] Naming convention consistente

---

*O melhor Zabbix não é o que monitora mais. É o que monitora certo. Comece pelo mínimo, adicione conforme a necessidade, e revise regularmente. Se o time ignora os alertas, o problema não é o time. É o monitoramento.*
