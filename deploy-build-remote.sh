#!/bin/bash
#
# Deploy com build no servidor ARM64
#

set -e

SERVER="ubuntu@144.22.221.3"
KEY="/home/deck/Documents/container2.key"
REMOTE_PATH="/home/ubuntu/nerdseverino.com.br"
LOCAL_PATH="/home/deck/nerdseverino.com.br"

echo "🚀 Deploy com build remoto..."
echo ""

# 1. Copiar arquivos
echo "📦 Copiando arquivos..."
rsync -avzL -e "ssh -C -i $KEY" \
  --exclude='public' \
  --exclude='.git' \
  --exclude='node_modules' \
  --exclude='*.backup' \
  --exclude='*.20*' \
  --exclude='themes' \
  --exclude='resources' \
  "$LOCAL_PATH/" \
  "$SERVER:$REMOTE_PATH/"

echo "✅ Arquivos copiados!"
echo ""

# 2. Build e restart no servidor
echo "🐳 Build e restart no servidor..."
ssh -C -i "$KEY" "$SERVER" << 'ENDSSH'
cd /home/ubuntu/nerdseverino.com.br
docker-compose down
docker build -t nerdseverino-blog .
docker-compose up -d hugo
sleep 3
docker-compose ps
docker-compose logs hugo | tail -5
ENDSSH

echo ""
echo "✅ Deploy concluído!"
echo "🌐 https://nerdseverino.com.br"
