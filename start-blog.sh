#!/bin/bash

echo "🚀 Iniciando blog Nerd Severino com Docker..."

# Verificar se Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando. Inicie o Docker primeiro."
    exit 1
fi

# Build da imagem
echo "📦 Construindo imagem Docker..."
docker-compose build

# Iniciar em modo desenvolvimento
echo "🔧 Iniciando servidor de desenvolvimento..."
echo "📍 Acesse: http://localhost:1313"
echo "⏹️  Para parar: Ctrl+C"

docker-compose up

echo "✅ Servidor parado."
