---
title: "Como um assistente de IA me ajudou a debugar um bug invisível no Docker COPY"
date: 2026-03-21T00:57:00-03:00
categories: DevOps
tags:
  - docker
  - debugging
  - ia
  - hugo
  - git
keywords:
  - docker copy bug
  - gitmodules
  - submodule
  - debugging
  - kiro
autoThumbnailImage: false
thumbnailImagePosition: top
---

Você já passou horas tentando entender por que um comando simples como `COPY static/ ./static/` simplesmente não copia todos os arquivos? Eu passei. E a resposta estava em um arquivo fantasma que ninguém lembrava que existia.

<!--more-->

## O cenário

Tenho um blog Hugo rodando em Docker. A estrutura é simples:

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

Dentro de `static/` existe uma pasta `admin/` com os arquivos do Netlify CMS — o painel de administração do blog. Tudo funcionava localmente. No servidor, após o build, a pasta `admin/` simplesmente não existia dentro do container.

## As hipóteses que testamos

### Hipótese 1: Cache do Docker

A primeira suspeita óbvia. Limpamos tudo:

```bash
docker system prune -af
docker build --no-cache -t blog .
```

Resultado: **1GB liberado, bug continua.**

### Hipótese 2: .dockerignore

Talvez alguma regra estivesse ignorando a pasta:

```bash
cat .dockerignore
grep -r "admin" .dockerignore
```

Resultado: **Nenhuma regra bloqueando admin/.**

### Hipótese 3: Arquivos não existem no servidor

Verificamos se os arquivos estavam lá:

```bash
ls -la static/admin/
git ls-files static/admin/ | wc -l
```

Resultado: **9 arquivos presentes no filesystem e no git.**

### Hipótese 4: Permissões

```bash
ls -la static/admin/
```

Resultado: **Permissões normais, leitura para todos.**

A essa altura, já tínhamos gasto um bom tempo. O Kiro (assistente de IA que uso no terminal) sugeriu um workaround temporário enquanto investigávamos:

```bash
docker cp ./static/admin container:/src/static/
docker restart container
```

Funcionou. O `/admin/` voltou a responder 200. Mas workaround não é solução.

## O root cause

Semanas depois, ao revisitar o problema, o Kiro fez a pergunta certa:

> "Será que o `.gitmodules` ainda referencia a pasta admin como submódulo?"

```bash
cat .gitmodules
```

```ini
[submodule "static/admin"]
    path = static/admin
    url = https://github.com/exemplo/netlify-cms-base.git
```

**Achamos o fantasma.**

## O que aconteceu

A história era a seguinte:

1. Originalmente, `static/admin/` era um **git submodule** apontando para outro repositório
2. Em algum momento, removemos o submódulo e adicionamos os arquivos diretamente ao repositório
3. Os arquivos foram commitados normalmente — `git ls-files` mostrava tudo
4. **Mas o `.gitmodules` nunca foi removido**

O Docker, ao construir o build context, respeita a estrutura do git. Com o `.gitmodules` presente, o Docker tratava `static/admin/` como um submódulo — e submódulos não são incluídos automaticamente no build context a menos que sejam inicializados.

Os arquivos existiam no filesystem, apareciam no `git ls-files`, mas o **build context do Docker** os ignorava silenciosamente.

## A correção

Três comandos:

```bash
git rm .gitmodules
rm -rf .git/modules/static/admin
git config --remove-section submodule.static/admin
```

Commit, push, rebuild. A pasta `admin/` apareceu dentro do container pela primeira vez sem workaround.

## Lições aprendidas

### 1. Submódulos deixam rastros

Remover um submódulo no git não é só deletar a pasta. Você precisa:
- Remover a entrada do `.gitmodules`
- Remover a entrada do `.git/config`
- Remover o diretório `.git/modules/<nome>`
- Remover a pasta do submódulo
- Commitar tudo

Se pular qualquer passo, fica um estado inconsistente que pode causar bugs silenciosos.

### 2. Docker COPY não falha — ele silencia

O `COPY static/ ./static/` não deu erro. Não mostrou warning. Simplesmente copiou o que conseguiu e seguiu em frente. Se tivesse falhado com um erro explícito, teríamos encontrado o problema em minutos.

### 3. Debugging sistemático funciona

O processo que seguimos:
1. **Observar** o sintoma (pasta vazia no container)
2. **Listar hipóteses** (cache, ignore, permissões, arquivos)
3. **Testar cada uma** com comandos específicos
4. **Aplicar workaround** para não bloquear
5. **Revisitar** com olhar fresco

A IA não "adivinhou" a resposta. Ela seguiu um processo metódico, testando e eliminando hipóteses até chegar na causa raiz.

### 4. Workarounds temporários são válidos

O `docker cp` nos permitiu continuar trabalhando enquanto o bug real não era resolvido. O importante é **documentar que é um workaround** e não esquecer de voltar para resolver de verdade.

## Conclusão

O bug mais difícil de encontrar não é o que gera um erro — é o que falha silenciosamente. Um arquivo `.gitmodules` de 3 linhas, esquecido após uma refatoração, causou horas de debugging e um workaround que ficou em produção por semanas.

Se você está tendo problemas com `COPY` no Docker e os arquivos existem no filesystem, verifique se não há fantasmas de submódulos antigos assombrando seu repositório.

```bash
# Verificação rápida
cat .gitmodules 2>/dev/null && echo "⚠️ Submódulos encontrados!" || echo "✅ Limpo"
```

---

*Este artigo foi escrito com auxílio do Kiro, assistente de IA para terminal. O processo de debugging descrito aconteceu em uma sessão real de trabalho.*
