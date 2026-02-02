#!/bin/bash
#
# Deploy completo: build local -> push -> pull remoto -> restart
#

set -e

IMAGE_NAME="systemcrashpoa/nerdseverino"
DATE_TAG=$(date +%Y%m%d%H%M)
SERVER="ubuntu@144.22.221.3"
KEY="/home/deck/Documents/container2.key"
REMOTE_PATH="/home/ubuntu/nerdseverino.com.br"

echo "🚀 Deploy completo..."
echo ""

# 1. Build local
echo "📦 Build da imagem..."
sudo docker build -t ${IMAGE_NAME}:latest -t ${IMAGE_NAME}:${DATE_TAG} .

# 2. Push para Docker Hub
echo ""
echo "📤 Push para Docker Hub..."
sudo docker push ${IMAGE_NAME}:latest
sudo docker push ${IMAGE_NAME}:${DATE_TAG}

# 3. Copiar docker-compose atualizado
echo ""
echo "📋 Copiando docker-compose..."
rsync -avz -e "ssh -C -i $KEY" \
  docker-compose.yml \
  "$SERVER:$REMOTE_PATH/"

# 4. Pull e restart no servidor
echo ""
echo "🔄 Pull e restart no servidor..."
ssh -C -i "$KEY" "$SERVER" << ENDSSH
cd $REMOTE_PATH
docker-compose pull hugo
docker-compose up -d hugo
docker-compose ps
ENDSSH

echo ""
echo "✅ Deploy concluído!"
echo "🌐 https://nerdseverino.com.br"
