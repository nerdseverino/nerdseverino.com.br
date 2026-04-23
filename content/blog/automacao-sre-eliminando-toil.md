---
title: "Automação SRE: Eliminando Toil com Scripts e CI/CD"
date: 2026-06-10T08:00:00-03:00
description: |
  Se você faz a mesma tarefa manual mais de 3 vezes, deveria ter automatizado na segunda.

  Toil é trabalho manual, repetitivo e reativo que não agrega valor duradouro. O Google recomenda menos de 50%.

  Como identificar e eliminar:

  ⚡ Listar tarefas repetitivas (frequência x tempo)
  ⚡ Automatizar as top 5 primeiro
  ⚡ Scripts com validação e rollback
  ⚡ CI/CD para o que precisa de aprovação
  ⚡ Medir: horas de toil antes vs depois

  Qual tarefa manual mais te irrita no dia a dia?

  🔗 https://nerdseverino.com.br/blog/automacao-sre-eliminando-toil/

  #SRE #Automação #Toil #DevOps #Scripts #CICD
cover:
  image: "/images/uploads/cover-automacao-sre.png"
  alt: "Cover"
  relative: false
categories:
  - SRE
tags:
  - serie-sre-na-pratica
  - sre
  - automação
  - toil
  - scripts
  - cicd
keywords:
  - automação sre
  - eliminar toil
  - scripts operação
autoThumbnailImage: false
thumbnailImagePosition: top
---

Se você faz a mesma tarefa manual mais de 3 vezes, deveria ter automatizado na segunda. Toil é o inimigo silencioso de times de SRE: consome tempo, não agrega valor e só cresce se não for combatido.

<!--more-->

## O que é Toil

Toil é trabalho que tem estas características:

| Característica | Exemplo |
|---------------|---------|
| Manual | Rodar script de limpeza de disco |
| Repetitivo | Toda semana, mesmo procedimento |
| Automatizável | Poderia ser um cron job |
| Reativo | Só faz quando alerta dispara |
| Sem valor duradouro | Não melhora o sistema, só mantém |
| Escala com o sistema | Mais servidores = mais toil |

## Identificando Toil

### Exercício: lista de tarefas repetitivas

Peça para cada pessoa do time listar:

```
| Tarefa | Frequência | Tempo | Automatizável? |
|--------|-----------|-------|----------------|
| Limpeza de disco | Semanal | 30 min | Sim |
| Restart de serviço X | 2x/semana | 15 min | Sim |
| Gerar relatório de custos | Mensal | 2 horas | Sim |
| Rotacionar logs | Diário | 10 min | Sim |
| Verificar backups | Diário | 20 min | Sim |
```

Calcule: `frequência x tempo x 4 semanas = horas/mês de toil`

### Priorização

Ordene por `frequência x tempo gasto`. Automatize as top 5 primeiro.

## Padrões de automação

### 1. Script com validação

Não basta automatizar. O script precisa validar que funcionou:

```bash
#!/bin/bash
set -euo pipefail

# Limpeza de disco
echo "Limpando logs antigos..."
find /var/log -name "*.gz" -mtime +30 -delete

# Validação
USAGE=$(df /var/log --output=pcent | tail -1 | tr -d ' %')
if [ "$USAGE" -gt 85 ]; then
    echo "ALERTA: Disco ainda acima de 85% após limpeza"
    exit 1
fi

echo "OK: Disco em ${USAGE}%"
```

### 2. Script com rollback

Para operações que podem dar errado:

```bash
#!/bin/bash
set -euo pipefail

CONFIG="/etc/nginx/nginx.conf"
BACKUP="${CONFIG}.bak-$(date +%Y%m%d%H%M%S)"

# Backup
cp "$CONFIG" "$BACKUP"

# Aplicar mudança
sed -i 's/worker_connections 1024/worker_connections 2048/' "$CONFIG"

# Validar
if ! nginx -t; then
    echo "Config inválida, revertendo..."
    cp "$BACKUP" "$CONFIG"
    exit 1
fi

# Aplicar
nginx -s reload
echo "OK: Config atualizada"
```

### 3. Automação com CI/CD

Para tarefas que precisam de aprovação ou audit trail:

```yaml
# .github/workflows/rotate-credentials.yml
name: Rotate Credentials
on:
  schedule:
    - cron: '0 6 1 * *'  # Primeiro dia do mês
  workflow_dispatch:       # Manual trigger

jobs:
  rotate:
    runs-on: ubuntu-latest
    steps:
    - name: Rotate API keys
      run: |
        # Script de rotação
        ./scripts/rotate-keys.sh
    - name: Notify
      run: |
        curl -s -X POST "$TELEGRAM_URL" \
          -d text="✅ Credenciais rotacionadas"
```

### 4. Self-healing

O nível mais alto: o sistema se corrige sozinho:

```bash
# Cron: verificar e reiniciar serviço se necessário
*/5 * * * * /scripts/check-and-restart.sh

# check-and-restart.sh
#!/bin/bash
if ! curl -sf http://localhost:8080/health > /dev/null; then
    systemctl restart myservice
    echo "$(date) - Serviço reiniciado automaticamente" >> /var/log/self-heal.log
    # Notificar (mas não acordar ninguém)
    sendx "⚠️ Serviço X reiniciado automaticamente"
fi
```

## Medindo redução de toil

### Antes

```
Toil total do time: 80 horas/mês
% do tempo: 50%
Top 5 tarefas: limpeza disco, restart, relatório, logs, backup
```

### Depois (3 meses de automação)

```
Toil total do time: 25 horas/mês
% do tempo: 15%
Automatizado: limpeza, restart, relatório, logs, backup check
Economia: 55 horas/mês = 7 dias de trabalho
```

Essas 55 horas agora vão para engenharia: melhorar o sistema, não só mantê-lo.

## Armadilhas

**Automatizar sem entender**: Se você não sabe por que faz a tarefa manual, não automatize. Primeiro entenda, depois automatize.

**Script sem log**: Automação silenciosa é perigosa. Sempre logue o que foi feito.

**Sem monitoramento da automação**: Se o cron job falha silenciosamente, você volta ao manual sem perceber.

**Over-engineering**: Nem tudo precisa de CI/CD e Terraform. Às vezes um script bash com cron resolve.

## Checklist de automação

- [ ] Listar tarefas repetitivas do time
- [ ] Calcular horas/mês de toil
- [ ] Priorizar top 5 por impacto
- [ ] Criar scripts com validação e rollback
- [ ] Agendar com cron ou CI/CD
- [ ] Monitorar execução (log + alerta de falha)
- [ ] Medir redução mensal

---

*Cada hora gasta automatizando uma tarefa repetitiva é uma hora que nunca mais será gasta nela. Comece pelas top 5, meça o antes e depois, e use o tempo liberado para engenharia de verdade. Toil zero é utopia, mas toil abaixo de 30% é alcançável.*
