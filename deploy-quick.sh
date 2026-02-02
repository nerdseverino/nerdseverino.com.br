#!/bin/bash
#
# Deploy rápido - apenas copia arquivos e reinicia
#

set -e

SERVER="ubuntu@144.22.221.3"
KEY="/home/deck/Documents/container2.key"
REMOTE_PATH="/home/ubuntu/nerdseverino.com.br"
LOCAL_PATH="/home/deck/nerdseverino.com.br"

echo "🚀 Deploy rápido..."

# Copiar arquivos
echo "📦 Copiando arquivos..."
rsync -avz -e "ssh -C -i $KEY" \
  --exclude='public' \
  --exclude='.git' \
  --exclude='node_modules' \
  --exclude='*.backup' \
  --exclude='*.20*' \
  --exclude='themes' \
  --exclude='resources' \
  "$LOCAL_PATH/" \
  "$SERVER:$REMOTE_PATH/"

# Reiniciar container
echo "🔄 Reiniciando container..."
ssh -C -i "$KEY" "$SERVER" "cd $REMOTE_PATH && docker-compose restart hugo"

echo ""
echo "✅ Deploy concluído!"
echo "🌐 https://nerdseverino.com.br"
