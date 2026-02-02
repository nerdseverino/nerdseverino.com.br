#!/bin/bash
#
# Script: deploy-blog.sh
# Descrição: Copia arquivos do blog para o servidor remoto
# Uso: ./deploy-blog.sh
#

set -e

# Configurações
SERVER="ubuntu@144.22.221.3"
KEY="/home/deck/Documents/container2.key"
REMOTE_PATH="/home/ubuntu/nerdseverino.com.br"
LOCAL_PATH="/home/deck/nerdseverino.com.br"

echo "🚀 Iniciando deploy do blog..."

# Criar diretório no servidor
echo "📁 Criando diretório no servidor..."
ssh -C -i "$KEY" "$SERVER" "mkdir -p $REMOTE_PATH"

# Copiar arquivos essenciais
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

echo "✅ Arquivos copiados com sucesso!"

# Instruções finais
echo ""
echo "📝 No servidor, execute:"
echo "   cd $REMOTE_PATH"
echo "   docker-compose pull"
echo "   docker-compose up -d hugo"
echo ""
echo "🌐 O blog estará disponível em:"
echo "   https://nerdseverino.com.br"
echo "   https://www.nerdseverino.com.br"
