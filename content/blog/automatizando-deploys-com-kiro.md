---
title: "Automatizando Deploys com Kiro CLI: Case Real"
date: 2026-05-08T08:00:00-03:00
description: |
  Montei o CI/CD completo de um blog Hugo via conversa no terminal.

  O Kiro criou tudo: Dockerfile, docker-compose, GitHub Actions, Netlify CMS, notificação Telegram.

  O fluxo final:
  ⚡ Editar post no browser (/admin)
  ⚡ Merge automático no GitHub
  ⚡ GitHub Actions faz deploy via SSH
  ⚡ Blog atualizado em 30 segundos
  ⚡ Telegram notifica sucesso/falha

  Zero clique no terminal. Zero SSH manual.

  Qual deploy você automatizaria primeiro?

  🔗 https://nerdseverino.com.br/blog/automatizando-deploys-com-kiro/

  #KiroCLI #CICD #DevOps #GitHubActions #Automação #SRE
categories:
  - DevOps
  - Ferramentas
tags:
  - serie-kiro-cli
  - kiro
  - cicd
  - deploy
  - github-actions
  - automação
keywords:
  - kiro cli deploy
  - github actions
  - automação deploy
  - ci cd
autoThumbnailImage: false
thumbnailImagePosition: top
---

Este post é um case real. Montei o pipeline de CI/CD completo deste blog usando o Kiro CLI, via conversa no terminal. Desde o Dockerfile até a notificação no Telegram, tudo foi criado, testado e corrigido em uma sessão.

<!--more-->

## O cenário

Blog Hugo rodando em container Docker num servidor ARM64 (Oracle Cloud). Antes da automação, o deploy era manual: editar arquivo, commit, SSH no servidor, git pull, docker restart.

O objetivo: editar um post no browser e o blog atualizar sozinho.

## O que o Kiro criou

### 1. Dockerfile otimizado

```dockerfile
FROM hugomods/hugo:exts-0.146.0
WORKDIR /src
COPY go.mod go.sum ./
COPY config.toml ./
COPY content/ ./content/
COPY assets/ ./assets/
COPY static/ ./static/
EXPOSE 1313
CMD ["hugo", "server", "--bind", "0.0.0.0"]
```

### 2. Docker Compose com volumes

```yaml
services:
  hugo:
    build: .
    container_name: blog
    ports:
      - "1313:1313"
    volumes:
      - ./content:/src/content:ro
      - ./static:/src/static:ro
      - ./config.toml:/src/config.toml:ro
    command: >
      hugo server --bind 0.0.0.0
      --baseURL https://meusite.com.br
      --appendPort=false
      --disableLiveReload
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost:1313"]
      interval: 30s
      timeout: 5s
      retries: 3
    restart: unless-stopped
```

Os volumes permitem que mudanças em conteúdo e configuração sejam detectadas sem rebuild do container.

### 3. GitHub Actions

```yaml
name: Deploy Blog
on:
  push:
    branches: [ master ]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Deploy to Server
      uses: appleboy/ssh-action@v1.0.3
      with:
        host: ${{ secrets.SERVER_HOST }}
        username: ${{ secrets.SERVER_USER }}
        key: ${{ secrets.SSH_KEY }}
        script: |
          cd /home/ubuntu/blog
          git pull origin master
          docker compose down
          docker build -t blog .
          docker compose up -d
          sleep 5
          docker compose ps

    - name: Notify Success
      if: success()
      run: |
        curl -s -X POST "https://api.telegram.org/bot${{ secrets.TELEGRAM_TOKEN }}/sendMessage" \
          -d chat_id="${{ secrets.TELEGRAM_CHAT_ID }}" \
          -d text="✅ Blog Deploy OK - ${{ github.event.head_commit.message }}"

    - name: Notify Failure
      if: failure()
      run: |
        curl -s -X POST "https://api.telegram.org/bot${{ secrets.TELEGRAM_TOKEN }}/sendMessage" \
          -d chat_id="${{ secrets.TELEGRAM_CHAT_ID }}" \
          -d text="❌ Blog Deploy FALHOU - ver logs"
```

### 4. Netlify CMS

Interface web em `/admin/` para editar posts sem tocar em código:

- Login com GitHub OAuth
- Editor visual com preview
- Workflow editorial (draft → review → publish)
- Commit automático no repositório

## Problemas que o Kiro resolveu

### Bug do Docker COPY

Os arquivos da pasta `/admin/` não eram copiados para dentro do container durante o build. Investigamos juntos e o Kiro identificou a causa raiz: um arquivo `.gitmodules` antigo que referenciava a pasta como submódulo. Removido o arquivo, o COPY voltou a funcionar.

### Data futura no Hugo

Um post criado com data no futuro não aparecia no blog. Hugo por padrão não publica posts com data futura. O Kiro identificou o problema comparando o timestamp do post com o horário do servidor.

### Config.toml não atualizava

Mudanças no `config.toml` não refletiam no blog porque o arquivo era copiado no build mas não montado como volume. Adicionamos `./config.toml:/src/config.toml:ro` no compose.

## O fluxo final

```
Autor edita post no /admin/
    ↓
Netlify CMS faz commit no GitHub
    ↓
GitHub Actions detecta push
    ↓
SSH no servidor → git pull → docker compose restart
    ↓
Hugo detecta mudança nos volumes
    ↓
Blog atualizado (~30 segundos)
    ↓
Telegram notifica: "✅ Deploy OK"
```

## Lições aprendidas

1. **Volumes > rebuild**: Montar content e config como volumes evita rebuild para mudanças de conteúdo
2. **Healthcheck salva**: Sem healthcheck, o container pode estar "running" mas o Hugo travado
3. **Notificação é essencial**: Saber que o deploy funcionou (ou falhou) sem precisar verificar manualmente
4. **Debug com AI funciona**: O Kiro investigou o bug do `.gitmodules` de forma sistemática, testando hipóteses até encontrar a causa raiz

---

*Automação de deploy não precisa ser complexa. Um Dockerfile, um compose, um workflow do GitHub Actions e uma notificação. O Kiro ajudou a criar tudo isso em uma sessão, incluindo debug de problemas que eu levaria horas para encontrar sozinho.*
