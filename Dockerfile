FROM hugomods/hugo:exts-0.146.0

WORKDIR /src

# Copiar arquivos de configuração
COPY go.mod go.sum ./
COPY config.toml ./

# Copiar conteúdo
COPY content/ ./content/
COPY assets/ ./assets/

# Copiar static (incluindo admin)
COPY static/ ./static/

# Expor porta
EXPOSE 1313

# Comando padrão para desenvolvimento
CMD ["hugo", "server", "--bind", "0.0.0.0", "--buildDrafts", "--buildFuture", "--disableFastRender"]
