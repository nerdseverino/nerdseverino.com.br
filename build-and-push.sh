#!/bin/bash
#
# Script: build-and-push.sh
# Descrição: Build da imagem Docker e push para Docker Hub
# Uso: ./build-and-push.sh
#

set -e

# Configurações
IMAGE_NAME="systemcrashpoa/nerdseverino"
DATE_TAG=$(date +%Y%m%d)

echo "🔨 Iniciando build e push da imagem..."
echo ""

# 1. Build da imagem
echo "📦 Construindo imagem Docker..."
sudo docker build -t nerdseverino-blog .

# 2. Criar tags
echo "🏷️  Criando tags..."
sudo docker tag nerdseverino-blog ${IMAGE_NAME}:latest
sudo docker tag nerdseverino-blog ${IMAGE_NAME}:${DATE_TAG}

echo "   ✓ ${IMAGE_NAME}:latest"
echo "   ✓ ${IMAGE_NAME}:${DATE_TAG}"

# 3. Push para Docker Hub
echo ""
echo "📤 Enviando imagens para Docker Hub..."
sudo docker push ${IMAGE_NAME}:latest
sudo docker push ${IMAGE_NAME}:${DATE_TAG}

echo ""
echo "✅ Build e push concluídos com sucesso!"
echo ""
echo "📋 Imagens disponíveis:"
echo "   - ${IMAGE_NAME}:latest"
echo "   - ${IMAGE_NAME}:${DATE_TAG}"
echo ""
echo "🚀 Próximo passo: Execute ./deploy-remote.sh para publicar no servidor"
