#!/bin/bash

echo "🏗️  Gerando build de produção..."

# Build da imagem se necessário
docker-compose build

# Gerar build estático
docker-compose --profile build run --rm hugo-build

echo "✅ Build gerado em ./public/"
echo "📁 Arquivos prontos para deploy"
