#!/bin/bash
#
# Script: deploy-remote.sh
# Descrição: Deploy completo no servidor remoto
# Uso: ./deploy-remote.sh
#

set -e

# Configurações
SERVER="ubuntu@144.22.221.3"
KEY="/home/deck/Documents/container2.key"
REMOTE_PATH="/home/ubuntu/nerdseverino.com.br"
LOCAL_PATH="/home/deck/nerdseverino.com.br"

echo "🚀 Iniciando deploy no servidor remoto..."
echo ""

# 1. Criar diretório no servidor
echo "📁 Preparando servidor..."
ssh -C -i "$KEY" "$SERVER" "mkdir -p $REMOTE_PATH"

# 2. Copiar arquivos
echo "📦 Copiando arquivos..."
rsync -avz -e "ssh -C -i $KEY" \
  --exclude='public' \
  --exclude='.git' \
  --exclude='node_modules' \
  --exclude='*.backup' \
  --exclude='*.20*' \
  --exclude='themes' \
  --exclude='resources' \
  --exclude='build-and-push.sh' \
  --exclude='deploy-remote.sh' \
  "$LOCAL_PATH/" \
  "$SERVER:$REMOTE_PATH/"

echo "✅ Arquivos copiados!"
echo ""

# 3. Executar comandos no servidor
echo "🐳 Atualizando container no servidor..."
ssh -C -i "$KEY" "$SERVER" << 'ENDSSH'
cd /home/ubuntu/nerdseverino.com.br

echo "   → Parando container antigo..."
docker-compose down 2>/dev/null || true

echo "   → Baixando imagem atualizada..."
docker-compose pull

echo "   → Iniciando container..."
docker-compose up -d hugo

echo "   → Verificando status..."
sleep 3
docker-compose ps

echo ""
echo "✅ Deploy concluído!"
ENDSSH

echo ""
echo "🌐 Blog disponível em:"
echo "   https://nerdseverino.com.br"
echo "   https://www.nerdseverino.com.br"
echo ""
echo "📊 Para ver logs:"
echo "   ssh -C -i $KEY $SERVER 'cd $REMOTE_PATH && docker-compose logs -f hugo'"
