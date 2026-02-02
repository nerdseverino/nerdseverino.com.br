# Blog Nerd Severino - Docker Setup

## 🚀 Início Rápido

```bash
# Iniciar servidor de desenvolvimento
./start-blog.sh

# Ou manualmente:
docker-compose up
```

Acesse: http://localhost:1313

## 🏗️ Build de Produção

```bash
# Gerar arquivos estáticos
./build-blog.sh

# Ou manualmente:
docker-compose --profile build run --rm hugo-build
```

## 📋 Comandos Disponíveis

- `docker-compose up` - Servidor desenvolvimento
- `docker-compose build` - Rebuild da imagem
- `docker-compose down` - Parar containers

## 🔧 Configurações

- **Hugo:** v0.139.2 (última versão)
- **Tema:** hugo-PaperMod
- **Go:** v1.21
- **Porta:** 1313

## 📝 Alterações Feitas

1. ✅ Corrigido tema de "assets" para "hugo-PaperMod"
2. ✅ Atualizado go.mod com módulo correto
3. ✅ Hugo atualizado para v0.139.2
4. ✅ Habilitado build no Netlify
5. ✅ Comentados links potencialmente quebrados
6. ✅ Scripts de automação criados

## 🔗 Links Comentados

Links externos foram comentados nos seguintes arquivos:
- `content/blog/coletânea-de-dicas-sobre-vi-vim.md`
- `content/blog/verificar-quais-portas-tem-servicos-escutando-no-linux.md`
- `content/blog/túneis-ssh.md`
