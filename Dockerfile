FROM hugomods/hugo:exts-0.146.0

WORKDIR /src

COPY go.mod go.sum ./
COPY config.toml ./
COPY content/ ./content/
COPY assets/ ./assets/
COPY static/ ./static/

RUN if [ ! -d "./static/admin" ] || [ -z "$(ls -A ./static/admin)" ]; then \
      echo "ERRO: Pasta admin vazia ou inexistente!"; \
      exit 1; \
    fi

EXPOSE 1313

CMD ["hugo", "server", "--bind", "0.0.0.0"]
