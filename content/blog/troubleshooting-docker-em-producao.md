---
title: "Troubleshooting Docker em Produção: Guia de Sobrevivência"
date: 2026-03-27T13:00:00-03:00
description: |
  Container reiniciando em loop e você não sabe por quê?

  O exit code te conta tudo:
  🔴 137 → OOM killer matou (memória estourou)
  🔴 139 → Segfault
  🟡 1 → Erro da aplicação
  🟢 0 → Saiu normal (mas não deveria)

  Um comando que pouca gente conhece:
  docker inspect <container> --format '{{.State.ExitCode}} - {{.State.OOMKilled}}'

  Se OOMKilled = true, não adianta reiniciar — precisa aumentar o limite ou investigar memory leak.

  Escrevi um guia completo: disco cheio fantasma, rede, overlay2, health checks.

  Qual o problema mais chato que você já teve com Docker em produção?

  🔗 https://nerdseverino.com.br/blog/troubleshooting-docker-em-producao/

  #Docker #DevOps #Containers #SRE #Troubleshooting
categories:
  - DevOps
  - SRE
tags:
  - serie-sre-na-pratica
  - docker
  - containers
  - troubleshooting
  - produção
  - sre
keywords:
  - docker troubleshooting
  - docker produção
  - container debug
  - docker logs
  - docker exec
  - overlay2
cover:
  image: "/images/uploads/cover-docker-troubleshooting.png"
  alt: "Cover"
  relative: false
autoThumbnailImage: false
thumbnailImagePosition: top
---

Container parou, aplicação não responde, disco encheu do nada. Se você roda Docker em produção, já passou por isso. Aqui vai o que eu aprendi resolvendo esses problemas no mundo real.

<!--more-->

## Diagnóstico rápido: os primeiros comandos

Antes de qualquer coisa, entenda o estado atual:

```bash
# Visão geral: o que está rodando, o que morreu
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Size}}"

# Consumo de recursos por container
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

# Espaço em disco usado pelo Docker
docker system df -v
```

O `docker system df` é o primeiro lugar para olhar quando disco enche. Imagens antigas, volumes órfãos e build cache acumulam rápido.

## Container reiniciando em loop

O clássico `Restarting (1) 5 seconds ago`. O container sobe e morre, sobe e morre:

```bash
# Ver os últimos logs antes da morte
docker logs --tail 50 <container>

# Ver o exit code (137 = OOM killed, 1 = erro da app, 139 = segfault)
docker inspect <container> --format '{{.State.ExitCode}} - {{.State.OOMKilled}}'

# Se OOMKilled = true, o container estourou o limite de memória
docker inspect <container> --format '{{.HostConfig.Memory}}'
```

Exit codes que importam:
- **0**: Saiu normalmente (mas não deveria ter saído)
- **1**: Erro genérico da aplicação
- **137**: Killed (OOM killer ou `docker kill`)
- **139**: Segmentation fault
- **143**: SIGTERM (graceful shutdown)

Se o exit code é 137 e `OOMKilled` é true, aumente o limite de memória ou investigue memory leak.

## Disco cheio: o vilão silencioso

Docker é um devorador de disco. As causas mais comuns:

```bash
# Quanto cada coisa ocupa
docker system df

# Imagens dangling (sem tag, restos de build)
docker images -f "dangling=true"

# Volumes órfãos (container morreu, volume ficou)
docker volume ls -f "dangling=true"

# Limpeza segura (remove só o que não está em uso)
docker system prune -f

# Limpeza agressiva (remove TUDO que não está rodando)
docker system prune -af --volumes
```

Mas o problema mais traiçoeiro é o **log do container**. Por padrão, Docker não limita o tamanho dos logs:

```bash
# Descobrir qual container está comendo disco com logs
du -sh /var/lib/docker/containers/*/
```

A solução é configurar log rotation no `/etc/docker/daemon.json`:

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

Isso limita cada container a 30MB de logs (3 arquivos de 10MB). Aplique e reinicie o Docker — mas atenção: isso só vale para containers novos. Os existentes mantêm a config antiga.

## Rede: container não conecta

Problemas de rede em Docker são frustrantes porque parecem aleatórios:

```bash
# Listar redes e quem está conectado
docker network ls
docker network inspect <rede> --format '{{range .Containers}}{{.Name}} {{.IPv4Address}}{{println}}{{end}}'

# DNS interno do Docker (resolve nomes de container)
docker exec <container> nslookup <outro_container>

# Testar conectividade entre containers
docker exec <container> wget -qO- http://<outro_container>:<porta>/health

# Container não resolve DNS externo? Verificar resolv.conf
docker exec <container> cat /etc/resolv.conf
```

Se DNS externo não funciona, geralmente é porque o `/etc/resolv.conf` do host aponta para `127.0.0.53` (systemd-resolved) e o container não consegue usar. Solução:

```json
{
  "dns": ["8.8.8.8", "1.1.1.1"]
}
```

## Investigando dentro do container

Às vezes você precisa entrar no container para investigar, mas ele não tem as ferramentas:

```bash
# Entrar no container
docker exec -it <container> sh

# Container não tem shell? Use nsenter pelo PID
PID=$(docker inspect <container> --format '{{.State.Pid}}')
nsenter -t $PID -m -u -i -n -p -- /bin/sh

# Copiar arquivo do container para o host (para análise)
docker cp <container>:/var/log/app.log /tmp/

# Copiar ferramenta para dentro do container
docker cp /usr/bin/strace <container>:/tmp/
```

O `nsenter` é a arma secreta. Ele entra no namespace do container usando o PID do processo no host. Funciona mesmo quando o container não tem shell.

## Container saudável mas aplicação lenta

O container está rodando, health check passa, mas a aplicação está lenta:

```bash
# Ver processos dentro do container
docker exec <container> ps aux

# Ver syscalls do processo principal (o que está travando?)
PID=$(docker inspect <container> --format '{{.State.Pid}}')
strace -p $PID -c -f -S time

# Ver conexões de rede do container
docker exec <container> ss -tnp

# Ver I/O do container
cat /sys/fs/cgroup/blkio/docker/<container_id>/blkio.throttle.io_service_bytes
```

Se `strace` mostra tempo em `futex` = lock contention. Se mostra tempo em `epoll_wait` = esperando I/O ou conexão. Se mostra tempo em `read`/`write` = I/O lento.

## Docker Compose: problemas comuns

```bash
# Ver logs de todos os serviços
docker compose logs -f --tail 20

# Recriar um serviço específico sem derrubar os outros
docker compose up -d --force-recreate <serviço>

# Ver a config final resolvida (variáveis expandidas)
docker compose config

# Verificar por que um serviço não sobe
docker compose ps -a
docker compose logs <serviço>
```

O `docker compose config` é essencial para debugar problemas de variáveis de ambiente. Ele mostra o YAML final com todas as variáveis resolvidas.

## Overlay2: quando o storage driver dá problema

```bash
# Ver qual container está usando mais espaço no overlay
docker ps -s --format "table {{.Names}}\t{{.Size}}"

# Encontrar o diretório do container no overlay2
docker inspect <container> --format '{{.GraphDriver.Data.MergedDir}}'

# Ver o que está ocupando espaço dentro do container
docker exec <container> du -sh /* 2>/dev/null | sort -rh | head -10
```

Se `/var/lib/docker/overlay2` está enorme e `docker system prune` não resolve, provavelmente tem layers de imagens antigas que ainda são referenciadas. O nuclear é:

```bash
# CUIDADO: para todos os containers, limpa tudo, recria
docker compose down
docker system prune -af --volumes
docker compose up -d
```

## Health checks que funcionam

Um health check mal configurado é pior que nenhum:

```yaml
healthcheck:
  test: ["CMD", "wget", "-q", "--spider", "http://localhost:8080/health"]
  interval: 30s
  timeout: 5s
  retries: 3
  start_period: 30s
```

O `start_period` é crucial. Sem ele, o container pode ser marcado como unhealthy antes de terminar de inicializar. 30 segundos é um bom padrão para a maioria das aplicações.

## Checklist de produção

Antes de colocar qualquer container em produção:

- [ ] Log rotation configurado (`max-size`, `max-file`)
- [ ] Limites de memória definidos (`mem_limit`)
- [ ] Health check configurado
- [ ] Restart policy (`unless-stopped` ou `on-failure`)
- [ ] Volumes para dados persistentes (não depender do writable layer)
- [ ] Rede dedicada (não usar a bridge default)
- [ ] Usuário não-root no Dockerfile (`USER`)
- [ ] `.dockerignore` configurado (build mais rápido e seguro)

---

*Docker em produção é simples até dar problema. Quando dá, ter esses comandos na ponta dos dedos faz a diferença entre resolver em 5 minutos ou ficar 2 horas no escuro. Salve esse post — você vai precisar dele às 3 da manhã.*
