FROM hugomods/hugo:exts-0.146.0

WORKDIR /src

# Copiar arquivos de configuração
COPY go.mod go.sum ./
COPY config.toml ./

# Copiar conteúdo
COPY content/ ./content/
COPY assets/ ./assets/

# Copiar static
COPY static/ ./static/

# Garantir que admin existe (workaround para submódulo)
RUN if [ ! -d "./static/admin" ] || [ -z "$(ls -A ./static/admin)" ]; then \
      echo "ERRO: Pasta admin vazia ou inexistente!"; \
      exit 1; \
    fi

# Expor porta
EXPOSE 1313

# Comando padrão para desenvolvimento
CMD ["hugo", "server", "--bind", "0.0.0.0", "--buildDrafts", "--buildFuture", "--disableFastRender"]
