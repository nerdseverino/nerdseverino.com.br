---
title: 7 - Uso Avançado do Terminal e Scripts
date: 2026-02-02T04:24:00.000Z
categories:
  - Curso
tags:
  - curso
  - linux
  - bash
  - shell
  - scripting
keywords:
  - linux
  - bash
  - shell
  - scripting
  - automacao
autoThumbnailImage: false
thumbnailImagePosition: top
coverImage: /images/uploads/9cbzwmsn.png
---

## Bash Scripting Básico

### Primeiro Script

```bash
#!/bin/bash
# meu_script.sh

echo "Olá, mundo!"
echo "Usuário: $USER"
echo "Diretório: $PWD"
echo "Data: $(date)"
```

**Tornar executável:**
```bash
chmod +x meu_script.sh
./meu_script.sh
```

### Shebang

```bash
#!/bin/bash          # Bash
#!/bin/sh            # Shell POSIX
#!/usr/bin/env bash  # Bash (portável)
#!/usr/bin/python3   # Python
```

### Variáveis

```bash
#!/bin/bash

# Definir variável
NOME="João"
IDADE=30

# Usar variável
echo "Nome: $NOME"
echo "Idade: ${IDADE}"

# Variáveis de ambiente
echo "Home: $HOME"
echo "Path: $PATH"

# Comando em variável
DATA=$(date +%Y-%m-%d)
ARQUIVOS=$(ls -1 | wc -l)

echo "Data: $DATA"
echo "Arquivos: $ARQUIVOS"
```

### Argumentos

```bash
#!/bin/bash

echo "Script: $0"
echo "Primeiro argumento: $1"
echo "Segundo argumento: $2"
echo "Todos argumentos: $@"
echo "Número de argumentos: $#"
```

**Uso:**
```bash
./script.sh arg1 arg2 arg3
```

### Entrada do Usuário

```bash
#!/bin/bash

# Ler entrada
echo "Digite seu nome:"
read NOME
echo "Olá, $NOME!"

# Ler com prompt
read -p "Digite sua idade: " IDADE
echo "Você tem $IDADE anos"

# Ler senha (oculta)
read -sp "Digite sua senha: " SENHA
echo
echo "Senha definida!"
```

## Estruturas de Controle

### if/else

```bash
#!/bin/bash

IDADE=18

if [ $IDADE -ge 18 ]; then
    echo "Maior de idade"
else
    echo "Menor de idade"
fi

# if/elif/else
NOTA=75

if [ $NOTA -ge 90 ]; then
    echo "A"
elif [ $NOTA -ge 80 ]; then
    echo "B"
elif [ $NOTA -ge 70 ]; then
    echo "C"
else
    echo "D"
fi
```

### Operadores de Comparação

**Números:**
```bash
-eq  # igual
-ne  # diferente
-gt  # maior que
-ge  # maior ou igual
-lt  # menor que
-le  # menor ou igual
```

**Strings:**
```bash
=    # igual
!=   # diferente
-z   # string vazia
-n   # string não vazia
```

**Arquivos:**
```bash
-e   # existe
-f   # é arquivo regular
-d   # é diretório
-r   # tem permissão de leitura
-w   # tem permissão de escrita
-x   # tem permissão de execução
-s   # não está vazio
```

### Exemplos Práticos

```bash
#!/bin/bash

# Verificar se arquivo existe
if [ -f "/etc/passwd" ]; then
    echo "Arquivo existe"
fi

# Verificar se diretório existe
if [ -d "/var/log" ]; then
    echo "Diretório existe"
fi

# Verificar se string está vazia
if [ -z "$VAR" ]; then
    echo "Variável vazia"
fi

# Múltiplas condições (AND)
if [ -f "arquivo.txt" ] && [ -r "arquivo.txt" ]; then
    echo "Arquivo existe e é legível"
fi

# Múltiplas condições (OR)
if [ "$USER" = "root" ] || [ "$UID" = "0" ]; then
    echo "Executando como root"
fi
```

### case

```bash
#!/bin/bash

read -p "Digite uma opção (1-3): " OPCAO

case $OPCAO in
    1)
        echo "Opção 1 selecionada"
        ;;
    2)
        echo "Opção 2 selecionada"
        ;;
    3)
        echo "Opção 3 selecionada"
        ;;
    *)
        echo "Opção inválida"
        ;;
esac
```

## Loops

### for

```bash
#!/bin/bash

# Loop simples
for i in 1 2 3 4 5; do
    echo "Número: $i"
done

# Loop com range
for i in {1..10}; do
    echo "Número: $i"
done

# Loop com step
for i in {0..100..10}; do
    echo "Número: $i"
done

# Loop em arquivos
for arquivo in *.txt; do
    echo "Processando: $arquivo"
done

# Loop estilo C
for ((i=0; i<10; i++)); do
    echo "Contador: $i"
done
```

### while

```bash
#!/bin/bash

# While simples
CONTADOR=0
while [ $CONTADOR -lt 5 ]; do
    echo "Contador: $CONTADOR"
    ((CONTADOR++))
done

# Ler arquivo linha por linha
while IFS= read -r linha; do
    echo "Linha: $linha"
done < arquivo.txt

# Loop infinito
while true; do
    echo "Pressione Ctrl+C para sair"
    sleep 1
done
```

### until

```bash
#!/bin/bash

CONTADOR=0
until [ $CONTADOR -ge 5 ]; do
    echo "Contador: $CONTADOR"
    ((CONTADOR++))
done
```

## Funções

```bash
#!/bin/bash

# Definir função
saudar() {
    echo "Olá, $1!"
}

# Chamar função
saudar "João"

# Função com retorno
somar() {
    local resultado=$(($1 + $2))
    echo $resultado
}

SOMA=$(somar 5 3)
echo "5 + 3 = $SOMA"

# Função com return
eh_par() {
    if [ $(($1 % 2)) -eq 0 ]; then
        return 0  # true
    else
        return 1  # false
    fi
}

if eh_par 4; then
    echo "4 é par"
fi
```

## Arrays

```bash
#!/bin/bash

# Criar array
FRUTAS=("maçã" "banana" "laranja")

# Acessar elementos
echo ${FRUTAS[0]}  # maçã
echo ${FRUTAS[1]}  # banana

# Todos elementos
echo ${FRUTAS[@]}

# Tamanho do array
echo ${#FRUTAS[@]}

# Adicionar elemento
FRUTAS+=("uva")

# Loop em array
for fruta in "${FRUTAS[@]}"; do
    echo "Fruta: $fruta"
done

# Array associativo (dicionário)
declare -A CORES
CORES[vermelho]="#FF0000"
CORES[verde]="#00FF00"
CORES[azul]="#0000FF"

echo ${CORES[vermelho]}
```

## Manipulação de Strings

```bash
#!/bin/bash

TEXTO="Hello World"

# Tamanho
echo ${#TEXTO}  # 11

# Substring
echo ${TEXTO:0:5}  # Hello

# Substituir
echo ${TEXTO/World/Bash}  # Hello Bash

# Maiúsculas/Minúsculas
echo ${TEXTO^^}  # HELLO WORLD
echo ${TEXTO,,}  # hello world

# Remover prefixo/sufixo
ARQUIVO="documento.txt"
echo ${ARQUIVO%.txt}  # documento
echo ${ARQUIVO#*.}    # txt
```

## Redirecionamento Avançado

```bash
# Redirecionar stdout
comando > arquivo.txt

# Redirecionar stderr
comando 2> erros.txt

# Redirecionar ambos
comando > saida.txt 2>&1
comando &> saida.txt

# Append
comando >> arquivo.txt

# Here document
cat << EOF > arquivo.txt
Linha 1
Linha 2
Linha 3
EOF

# Here string
grep "palavra" <<< "texto com palavra"

# Pipe
comando1 | comando2 | comando3

# Tee (salvar e mostrar)
comando | tee arquivo.txt

# Process substitution
diff <(ls dir1) <(ls dir2)
```

## Processamento de Texto

### grep - Buscar Padrões

```bash
# Buscar em arquivo
grep "palavra" arquivo.txt

# Case insensitive
grep -i "palavra" arquivo.txt

# Inverter match
grep -v "palavra" arquivo.txt

# Contar ocorrências
grep -c "palavra" arquivo.txt

# Mostrar número da linha
grep -n "palavra" arquivo.txt

# Recursivo em diretório
grep -r "palavra" /var/log/

# Regex
grep -E "^[0-9]+" arquivo.txt

# Múltiplos padrões
grep -E "erro|warning|fatal" log.txt
```

### sed - Stream Editor

```bash
# Substituir primeira ocorrência
sed 's/antigo/novo/' arquivo.txt

# Substituir todas ocorrências
sed 's/antigo/novo/g' arquivo.txt

# Substituir e salvar
sed -i 's/antigo/novo/g' arquivo.txt

# Deletar linhas
sed '/padrao/d' arquivo.txt

# Imprimir linhas específicas
sed -n '10,20p' arquivo.txt

# Múltiplos comandos
sed -e 's/foo/bar/g' -e 's/hello/world/g' arquivo.txt
```

### awk - Processamento de Texto

```bash
# Imprimir coluna
awk '{print $1}' arquivo.txt

# Múltiplas colunas
awk '{print $1, $3}' arquivo.txt

# Com separador
awk -F: '{print $1}' /etc/passwd

# Condição
awk '$3 > 100 {print $1}' arquivo.txt

# Somar coluna
awk '{sum += $1} END {print sum}' numeros.txt

# Contar linhas
awk 'END {print NR}' arquivo.txt
```

### cut - Extrair Colunas

```bash
# Por delimitador
cut -d: -f1 /etc/passwd

# Por posição
cut -c1-10 arquivo.txt

# Múltiplos campos
cut -d: -f1,3,6 /etc/passwd
```

### sort - Ordenar

```bash
# Ordenar
sort arquivo.txt

# Ordem reversa
sort -r arquivo.txt

# Numérico
sort -n numeros.txt

# Por coluna
sort -k2 arquivo.txt

# Único (remover duplicatas)
sort -u arquivo.txt
```

### uniq - Remover Duplicatas

```bash
# Remover duplicatas adjacentes
uniq arquivo.txt

# Contar ocorrências
uniq -c arquivo.txt

# Mostrar apenas duplicatas
uniq -d arquivo.txt

# Mostrar apenas únicos
uniq -u arquivo.txt
```

## Scripts Práticos

### 1. Backup Automático

```bash
#!/bin/bash

# backup.sh
ORIGEM="/home/usuario/documentos"
DESTINO="/backup"
DATA=$(date +%Y%m%d_%H%M%S)
ARQUIVO="backup_$DATA.tar.gz"

echo "Iniciando backup..."
tar czf "$DESTINO/$ARQUIVO" "$ORIGEM"

if [ $? -eq 0 ]; then
    echo "Backup concluído: $ARQUIVO"
else
    echo "Erro no backup!"
    exit 1
fi

# Manter apenas últimos 7 backups
cd "$DESTINO"
ls -t backup_*.tar.gz | tail -n +8 | xargs rm -f
```

### 2. Monitor de Disco

```bash
#!/bin/bash

# monitor_disco.sh
LIMITE=80

df -h | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{print $5 " " $1}' | while read saida; do
    USO=$(echo $saida | awk '{print $1}' | sed 's/%//g')
    PARTICAO=$(echo $saida | awk '{print $2}')
    
    if [ $USO -ge $LIMITE ]; then
        echo "ALERTA: $PARTICAO está com $USO% de uso!"
    fi
done
```

### 3. Verificar Serviços

```bash
#!/bin/bash

# check_services.sh
SERVICOS=("nginx" "mysql" "ssh")

for servico in "${SERVICOS[@]}"; do
    if systemctl is-active --quiet $servico; then
        echo "✓ $servico está rodando"
    else
        echo "✗ $servico está parado"
        # Tentar reiniciar
        sudo systemctl start $servico
    fi
done
```

### 4. Limpeza de Logs

```bash
#!/bin/bash

# limpar_logs.sh
LOG_DIR="/var/log"
DIAS=30

echo "Limpando logs com mais de $DIAS dias..."

find $LOG_DIR -name "*.log" -type f -mtime +$DIAS -exec rm -f {} \;
find $LOG_DIR -name "*.gz" -type f -mtime +$DIAS -exec rm -f {} \;

echo "Limpeza concluída!"
```

### 5. Deploy Simples

```bash
#!/bin/bash

# deploy.sh
REPO="https://github.com/usuario/projeto.git"
DIR="/var/www/projeto"

echo "Iniciando deploy..."

# Backup
if [ -d "$DIR" ]; then
    cp -r "$DIR" "${DIR}_backup_$(date +%Y%m%d)"
fi

# Atualizar código
cd "$DIR" || exit 1
git pull origin main

# Instalar dependências
npm install

# Build
npm run build

# Reiniciar serviço
sudo systemctl restart projeto

echo "Deploy concluído!"
```

## Debugging

```bash
# Modo debug (mostra comandos)
bash -x script.sh

# Ou no script
#!/bin/bash
set -x

# Parar em erro
set -e

# Parar em variável não definida
set -u

# Combinado
set -euo pipefail

# Debug condicional
if [ "$DEBUG" = "1" ]; then
    echo "Debug: variável = $VAR"
fi
```

## Boas Práticas

### 1. Use Aspas

```bash
# Ruim
rm $ARQUIVO

# Bom
rm "$ARQUIVO"
```

### 2. Verifique Erros

```bash
comando
if [ $? -ne 0 ]; then
    echo "Erro!"
    exit 1
fi

# Ou
comando || { echo "Erro!"; exit 1; }
```

### 3. Use Funções

```bash
# Ruim - código repetido
echo "Processando arquivo1..."
processar arquivo1
echo "Concluído!"

echo "Processando arquivo2..."
processar arquivo2
echo "Concluído!"

# Bom - função
processar_arquivo() {
    echo "Processando $1..."
    processar "$1"
    echo "Concluído!"
}

processar_arquivo arquivo1
processar_arquivo arquivo2
```

### 4. Documente

```bash
#!/bin/bash
#
# Script: backup.sh
# Descrição: Realiza backup de diretórios
# Autor: Seu Nome
# Data: 2026-02-02
#
# Uso: ./backup.sh [origem] [destino]
#

# Verificar argumentos
if [ $# -ne 2 ]; then
    echo "Uso: $0 [origem] [destino]"
    exit 1
fi
```

## Comandos de Referência Rápida

```bash
# Criar script
vim script.sh
chmod +x script.sh

# Executar
./script.sh
bash script.sh

# Debug
bash -x script.sh

# Variáveis
VAR="valor"
echo $VAR

# If
if [ condição ]; then
    comando
fi

# Loop
for i in {1..10}; do
    echo $i
done

# Função
funcao() {
    echo "Olá"
}
```

---

**Próximo capítulo**: 8 - Segurança no Linux

**Capítulo anterior**: [6 - Configuração de Rede](https://www.nerdseverino.com.br/linux/6-configura%C3%A7%C3%A3o-de-rede-e-conectividade/)
