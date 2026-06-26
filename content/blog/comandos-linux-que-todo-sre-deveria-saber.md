---
title: "Comandos Linux que Todo SRE Deveria Saber"
date: 2026-03-26T08:50:00-03:00
description: |
  O alerta toca às 3h da manhã. Você entra no servidor. O que roda primeiro?

  Depois de mais de uma década resolvendo incidentes, esses são os primeiros 60 segundos:

  ⚡ uptime → load average e tempo de pé
  ⚡ dmesg -T | tail -20 → kernel matou algo?
  ⚡ free -h → swap estourado = problema
  ⚡ df -h → disco cheio causa 30% dos incidentes
  ⚡ ss -tlnp → portas abertas e quem ouve

  Se o load está alto, o dmesg mostra OOM kill e o swap está cheio — diagnóstico em 30 segundos.

  O post completo tem seções sobre strace, /proc, iotop e one-liners que já me salvaram.

  E você, qual é o primeiro comando que roda quando entra num servidor com problema?

  🔗 https://nerdseverino.com.br/blog/comandos-linux-que-todo-sre-deveria-saber/

  #Linux #SRE #DevOps #Troubleshooting #OnCall
categories:
  - Linux
  - SRE
tags:
  - serie-sre-na-pratica
  - linux
  - sre
  - troubleshooting
  - performance
  - observabilidade
keywords:
  - linux troubleshooting
  - sre comandos
  - performance linux
  - diagnóstico servidor
  - strace
  - ss
  - dmesg
cover:
  image: "/images/uploads/cover-linux-sre-commands.jpg"
  alt: "Cover"
  relative: false
autoThumbnailImage: false
thumbnailImagePosition: top
---

Quando o alerta toca às 3 da manhã e o sistema está degradado, não adianta ter dashboard bonito se você não sabe investigar no terminal. Esses são os comandos que me salvaram em mais de uma década lidando com incidentes em produção.

<!--more-->

## Os primeiros 60 segundos

Quando você entra num servidor com problema, essa sequência te dá um panorama rápido:

```bash
uptime                  # load average e há quanto tempo está de pé
dmesg -T | tail -20     # mensagens do kernel (OOM killer, disco, rede)
journalctl -p err --since "1h ago"  # erros da última hora
free -h                 # memória (swap usado = problema)
df -h                   # disco cheio é causa de 30% dos incidentes
ps auxf --sort=-%mem | head -15  # quem está comendo memória
ss -tlnp                # portas abertas e quem está ouvindo
```

Se o `uptime` mostra load average alto, o `dmesg` mostra OOM kill e o `free` mostra swap estourado — você já tem o diagnóstico em 30 segundos.

## Rede: ss é o novo netstat

O `netstat` morreu. Use `ss`:

```bash
# Conexões estabelecidas por estado
ss -s

# Quem está conectado na porta 443
ss -tnp state established '( dport = 443 or sport = 443 )'

# Conexões em TIME_WAIT (muitas = problema de connection pooling)
ss -tan state time-wait | wc -l

# Socket com fila de recebimento cheia (backlog)
ss -tlnp | awk '$2 > 0'
```

A coluna `Recv-Q` no `ss -tlnp` é ouro: se está maior que zero num socket LISTEN, significa que o processo não está aceitando conexões rápido o suficiente. Isso é o tipo de coisa que não aparece em nenhum dashboard.

## strace: quando você não tem mais nada

O `strace` é o último recurso e o mais poderoso. Ele mostra exatamente o que um processo está fazendo no nível de syscalls:

```bash
# Processo travado? Veja o que ele está esperando
strace -p <PID> -e trace=network,write -f

# Processo lento? Veja onde gasta tempo
strace -p <PID> -c -f -S time

# Qual arquivo ele está tentando abrir e falhando?
strace -p <PID> -e trace=openat 2>&1 | grep -v "= [0-9]"
```

O `-c` com `-S time` te dá um resumo estatístico das syscalls. Se 90% do tempo está em `futex`, o processo está esperando lock. Se está em `read` ou `recvfrom`, está esperando I/O ou rede.

## /proc: o filesystem que ninguém lê

Tudo no Linux é arquivo, e `/proc` é onde o kernel expõe o estado do sistema:

```bash
# Limites do processo (nofile = max file descriptors)
cat /proc/<PID>/limits

# File descriptors abertos (leak de FD = processo abrindo e não fechando)
ls /proc/<PID>/fd | wc -l

# Memória detalhada do processo
cat /proc/<PID>/status | grep -E "VmRSS|VmSwap|Threads"

# Conexões de rede do processo (sem precisar de ss)
cat /proc/<PID>/net/tcp

# Pressão de recursos (PSI - Pressure Stall Information)
cat /proc/pressure/cpu
cat /proc/pressure/memory
cat /proc/pressure/io
```

O PSI (Pressure Stall Information) é relativamente novo e absurdamente útil. Ele te diz quanto tempo os processos ficaram esperando por CPU, memória ou I/O. Se `some avg10` está acima de 10%, você tem um gargalo real.

## Disco: iotop e iostat

Disco lento é silencioso. O sistema fica "estranho", comandos demoram, mas CPU e memória parecem ok:

```bash
# Quem está fazendo I/O agora
iotop -oP

# Latência e throughput por dispositivo
iostat -xz 1 5

# Verificar se tem processo em D state (uninterruptible sleep = esperando I/O)
ps aux | awk '$8 ~ /D/'
```

No `iostat`, preste atenção em:
- `await` > 10ms em SSD = problema
- `%util` > 80% = disco saturado
- `avgqu-sz` alto = fila de I/O crescendo

## Memória: além do free -h

```bash
# Top 10 processos por memória RSS real
ps aux --sort=-%mem | head -11

# Cache vs disponível (Available é o que importa, não Free)
cat /proc/meminfo | grep -E "MemTotal|MemAvailable|SwapTotal|SwapFree|Dirty|Writeback"

# Quem foi pro swap (e quanto)
for pid in /proc/[0-9]*; do
  swap=$(awk '/VmSwap/{print $2}' "$pid/status" 2>/dev/null)
  [ "${swap:-0}" -gt 0 ] && echo "$swap KB $(cat $pid/cmdline 2>/dev/null | tr '\0' ' ')"
done | sort -rn | head -10

# OOM score (quem o kernel vai matar primeiro)
for pid in /proc/[0-9]*; do
  score=$(cat "$pid/oom_score" 2>/dev/null)
  [ "${score:-0}" -gt 100 ] && echo "$score $(cat $pid/cmdline 2>/dev/null | tr '\0' ' ')"
done | sort -rn | head -5
```

Dica: `MemAvailable` no `/proc/meminfo` é o número real de memória disponível. O `MemFree` não conta cache reutilizável e vai te enganar.

## Logs: journalctl como profissional

```bash
# Erros desde o último boot
journalctl -b -p err

# Seguir logs de um serviço específico
journalctl -u nginx -f --no-pager

# Logs entre duas datas
journalctl --since "2026-03-25 22:00" --until "2026-03-26 02:00"

# Tamanho do journal (se está comendo disco)
journalctl --disk-usage

# Logs do kernel (equivalente ao dmesg mas com filtros)
journalctl -k --since "1h ago"
```

## One-liners que já me salvaram

```bash
# Qual processo está deletando arquivos mas mantendo o FD aberto (disco cheio fantasma)
lsof +L1

# Encontrar arquivos grandes modificados recentemente
find / -xdev -type f -size +100M -mtime -1 -ls 2>/dev/null

# Verificar se DNS está lento (causa oculta de lentidão)
time dig google.com

# Testar conectividade TCP sem depender de ping
timeout 3 bash -c '</dev/tcp/10.0.0.1/443' && echo "OK" || echo "FALHOU"

# Monitorar syscalls de todos os processos de um serviço
strace -fp $(pgrep -d, nginx) -e trace=network -c
```

## A mentalidade SRE

Ferramentas são importantes, mas o que diferencia um SRE é o método:

1. **Observe** antes de agir — `uptime`, `dmesg`, `free`, `df`
2. **Forme uma hipótese** — "parece problema de disco"
3. **Teste a hipótese** — `iostat`, `iotop`, processos em D state
4. **Confirme** — encontre a causa raiz, não o sintoma
5. **Documente** — postmortem, mesmo que informal

Não reinicie o serviço antes de coletar evidências. O restart resolve o sintoma e destrói a cena do crime.

---

*Esses comandos funcionam em qualquer distribuição Linux moderna. Alguns precisam de pacotes extras (`sysstat` para iostat, `iotop`, `strace`), mas a maioria já vem instalada. Se você é SRE e não tem esses pacotes no seu servidor, instale agora — antes do próximo incidente.*
