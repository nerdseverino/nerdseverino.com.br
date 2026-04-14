---
title: 7 - Uso Avançado do Terminal e Scripts
weight: 7
date: 2026-02-02T04:23:00.000Z
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

## Arquivos de Inicialização do Bash

Quando você abre um terminal, o Bash lê uma sequência de arquivos de configuração. Entender quais são e quando são lidos é fundamental para configurar variáveis de ambiente, aliases e PATH corretamente.

### Login Shell vs Non-Login Shell

| Tipo | Quando | Arquivos lidos |
|------|--------|---------------|
| Login shell | SSH, console, `su -` | `/etc/profile` → `~/.bash_profile` → `~/.bash_login` → `~/.profile` |
| Non-login shell | Abrir terminal no desktop | `/etc/bash.bashrc` → `~/.bashrc` |

### Arquivos Principais

```bash
# /etc/profile — Global, executado em login shells (todos os usuários)
# /etc/bash.bashrc — Global, executado em non-login shells

# ~/.bash_profile — Pessoal, login shell (lê ~/.bashrc geralmente)
# ~/.bashrc — Pessoal, non-login shell (aliases, funções, prompt)
# ~/.bash_logout — Executado ao sair de login shell
```

### Onde colocar o quê

| O que configurar | Onde colocar |
|-----------------|-------------|
| Variáveis de ambiente (PATH, EDITOR) | `~/.bash_profile` ou `~/.profile` |
| Aliases e funções | `~/.bashrc` |
| Configurações globais | `/etc/profile.d/*.sh` |
| Prompt (PS1) | `~/.bashrc` |

### Exemplo prático

```bash
# ~/.bashrc — carregado em todo terminal novo
export EDITOR=vim
export PATH="$HOME/.local/bin:$PATH"

alias ll='ls -lah'
alias gs='git status'
alias k='kubectl'

# Prompt colorido
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
```

```bash
# ~/.bash_profile — garante que .bashrc é lido em login shells
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
```

### Recarregar sem fechar o terminal

```bash
source ~/.bashrc
# ou
. ~/.bashrc
```

## Aspas Simples e Duplas

A diferença entre aspas simples e duplas é uma das fontes mais comuns de bugs em shell scripts.

### Aspas Duplas `" "` — Interpretam variáveis

```bash
nome="Linux"
echo "Bem-vindo ao $nome"     # Saída: Bem-vindo ao Linux
echo "Home: $HOME"            # Saída: Home: /home/usuario
echo "Data: $(date)"          # Saída: Data: Mon Apr 14 15:30:00 2026
```

### Aspas Simples `' '` — Texto literal

```bash
nome="Linux"
echo 'Bem-vindo ao $nome'     # Saída: Bem-vindo ao $nome
echo 'Home: $HOME'            # Saída: Home: $HOME
echo 'Data: $(date)'          # Saída: Data: $(date)
```

### Sem aspas — Perigoso

```bash
arquivo="meu arquivo.txt"
cat $arquivo                   # ERRO: tenta abrir "meu" e "arquivo.txt"
cat "$arquivo"                 # CORRETO: abre "meu arquivo.txt"
```

### Resumo

| Tipo | Variáveis | Comandos `$()` | Espaços | Uso |
|------|-----------|----------------|---------|-----|
| `"duplas"` | ✅ Expande | ✅ Executa | ✅ Preserva | Maioria dos casos |
| `'simples'` | ❌ Literal | ❌ Literal | ✅ Preserva | Texto exato, sem interpretação |
| Sem aspas | ✅ Expande | ✅ Executa | ❌ Quebra | Evitar |

**Regra prática:** Na dúvida, use aspas duplas. Use aspas simples quando quiser que nada seja interpretado.

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

## Editores de Texto no Terminal

### vim - Editor Avançado

O vim é o editor padrão em praticamente todo servidor Linux. Tem curva de aprendizado, mas é extremamente produtivo depois que você aprende os modos.

**Modos do vim:**

| Modo | Tecla | Função |
|------|-------|--------|
| Normal | `Esc` | Navegação e comandos |
| Inserção | `i` | Digitar texto |
| Visual | `v` | Selecionar texto |
| Comando | `:` | Executar comandos |

**Comandos essenciais:**

```bash
vim arquivo.txt          # Abrir arquivo

# Modo Normal (navegação)
h j k l                  # Esquerda, baixo, cima, direita
gg                       # Ir para início do arquivo
G                        # Ir para fim do arquivo
:42                      # Ir para linha 42
w                        # Pular para próxima palavra
b                        # Voltar uma palavra
0                        # Início da linha
$                        # Fim da linha

# Entrar em modo de inserção
i                        # Inserir antes do cursor
a                        # Inserir depois do cursor
o                        # Nova linha abaixo
O                        # Nova linha acima
A                        # Inserir no fim da linha

# Edição no modo Normal
dd                       # Deletar linha
yy                       # Copiar linha
p                        # Colar
u                        # Desfazer
Ctrl+r                   # Refazer
x                        # Deletar caractere
dw                       # Deletar palavra
d$                       # Deletar até fim da linha
.                        # Repetir último comando

# Busca
/texto                   # Buscar para frente
?texto                   # Buscar para trás
n                        # Próxima ocorrência
N                        # Ocorrência anterior

# Substituir
:%s/antigo/novo/g        # Substituir todas ocorrências
:%s/antigo/novo/gc       # Substituir com confirmação

# Salvar e sair
:w                       # Salvar
:q                       # Sair
:wq                      # Salvar e sair
:q!                      # Sair sem salvar
ZZ                       # Salvar e sair (atalho)
```

### nano - Editor Simples

O nano é mais intuitivo que o vim. Ideal para edições rápidas:

```bash
nano arquivo.txt         # Abrir arquivo
```

**Atalhos principais (^ = Ctrl):**

| Atalho | Função |
|--------|--------|
| Ctrl+O | Salvar |
| Ctrl+X | Sair |
| Ctrl+K | Recortar linha |
| Ctrl+U | Colar |
| Ctrl+W | Buscar |
| Ctrl+\ | Buscar e substituir |
| Ctrl+G | Ajuda |
| Alt+U | Desfazer |
| Ctrl+_ | Ir para linha |

### top e htop - Monitoramento de Processos

O `top` mostra processos em tempo real:

```bash
top                      # Iniciar monitor
```

**Comandos dentro do top:**

| Tecla | Função |
|-------|--------|
| P | Ordenar por CPU |
| M | Ordenar por memória |
| k | Matar processo (digitar PID) |
| r | Alterar prioridade (renice) |
| c | Mostrar comando completo |
| 1 | Mostrar cada CPU individual |
| q | Sair |

**htop** é uma versão melhorada:

```bash
sudo apt install htop    # Instalar
htop                     # Executar
```

Diferenças do htop:
- Interface colorida e mais legível
- Scroll horizontal e vertical
- Mouse funciona
- F2 para configurar, F3 buscar, F5 árvore, F9 matar

## Expressões Regulares

Expressões regulares (regex) são padrões para buscar e manipular texto. São usadas em `grep`, `sed`, `awk` e muitas outras ferramentas.

### Metacaracteres Básicos

| Caractere | Significado | Exemplo |
|-----------|-------------|---------|
| `.` | Qualquer caractere | `a.c` casa "abc", "a1c" |
| `*` | Zero ou mais do anterior | `ab*c` casa "ac", "abc", "abbc" |
| `+` | Um ou mais do anterior | `ab+c` casa "abc", "abbc" (não "ac") |
| `?` | Zero ou um do anterior | `ab?c` casa "ac", "abc" |
| `^` | Início da linha | `^root` linhas que começam com "root" |
| `$` | Fim da linha | `bash$` linhas que terminam com "bash" |
| `[]` | Conjunto de caracteres | `[aeiou]` qualquer vogal |
| `[^]` | Negação do conjunto | `[^0-9]` qualquer coisa que não seja número |
| `\|` | OU lógico | `cat\|dog` casa "cat" ou "dog" |
| `()` | Agrupamento | `(ab)+` casa "ab", "abab" |
| `\b` | Limite de palavra | `\broot\b` casa "root" mas não "rooted" |

### Classes de Caracteres

| Classe | Equivalente | Significado |
|--------|-------------|-------------|
| `[0-9]` | `\d` | Dígitos |
| `[a-zA-Z]` | `\w` (com dígitos) | Letras |
| `[[:space:]]` | `\s` | Espaços em branco |
| `[[:upper:]]` | `[A-Z]` | Maiúsculas |
| `[[:lower:]]` | `[a-z]` | Minúsculas |

### Exemplos Práticos

```bash
# Linhas que começam com # (comentários)
grep "^#" /etc/ssh/sshd_config

# Linhas que NÃO são comentários nem vazias
grep -v "^#\|^$" /etc/ssh/sshd_config

# Endereços IP
grep -oE "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" /var/log/auth.log

# Emails
grep -oE "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" arquivo.txt

# Linhas com números de telefone (formato BR)
grep -E "\([0-9]{2}\) [0-9]{4,5}-[0-9]{4}" contatos.txt

# Palavras duplicadas
grep -E "\b(\w+)\s+\1\b" texto.txt

# Usar com sed para substituir
sed -E 's/[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}/***CPF***/g' dados.txt
```

### Regex no grep: BRE vs ERE

```bash
# BRE (Basic Regular Expression) - padrão do grep
grep "ab\+c" arquivo       # Precisa escapar +

# ERE (Extended Regular Expression) - grep -E ou egrep
grep -E "ab+c" arquivo     # Não precisa escapar
```

Use `grep -E` (ou `egrep`) para evitar escapar metacaracteres.

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

## Compactação e Compressão

### Conceitos

- **Compactação (tar)**: Agrupa vários arquivos em um só (sem reduzir tamanho)
- **Compressão (gzip, bzip2, xz)**: Reduz o tamanho do arquivo
- Na prática, usamos os dois juntos: `tar` agrupa + compressor reduz

### tar - Tape Archive

```bash
# Criar arquivo tar (sem compressão)
tar -cf backup.tar /diretorio/

# Extrair
tar -xf backup.tar

# Listar conteúdo
tar -tf backup.tar

# Verbose (mostrar arquivos)
tar -cvf backup.tar /diretorio/
```

### tar + gzip (.tar.gz ou .tgz)

Compressão mais rápida, tamanho médio. O mais usado no dia a dia:

```bash
# Compactar
tar -czf backup.tar.gz /diretorio/

# Extrair
tar -xzf backup.tar.gz

# Extrair em diretório específico
tar -xzf backup.tar.gz -C /destino/
```

### tar + bzip2 (.tar.bz2)

Compressão melhor que gzip, mais lento:

```bash
# Compactar
tar -cjf backup.tar.bz2 /diretorio/

# Extrair
tar -xjf backup.tar.bz2
```

### tar + xz (.tar.xz)

Melhor compressão, mais lento. Ideal para distribuição de arquivos:

```bash
# Compactar
tar -cJf backup.tar.xz /diretorio/

# Extrair
tar -xJf backup.tar.xz
```

### Comparação

| Formato | Flag tar | Velocidade | Compressão |
|---------|----------|-----------|------------|
| gzip (.tar.gz) | `-z` | Rápido | Boa |
| bzip2 (.tar.bz2) | `-j` | Médio | Melhor |
| xz (.tar.xz) | `-J` | Lento | Excelente |

### Comandos individuais de compressão

```bash
# gzip (substitui o arquivo original)
gzip arquivo.txt              # Cria arquivo.txt.gz
gunzip arquivo.txt.gz         # Descomprime

# bzip2
bzip2 arquivo.txt             # Cria arquivo.txt.bz2
bunzip2 arquivo.txt.bz2       # Descomprime

# xz
xz arquivo.txt                # Cria arquivo.txt.xz
unxz arquivo.txt.xz           # Descomprime

# Manter original (-k)
gzip -k arquivo.txt           # Mantém arquivo.txt e cria .gz
xz -k arquivo.txt             # Mantém arquivo.txt e cria .xz
```

### zip/unzip (compatibilidade com Windows)

```bash
# Compactar
zip -r backup.zip /diretorio/

# Extrair
unzip backup.zip

# Listar conteúdo
unzip -l backup.zip
```

## Agendar Tarefas com Cron

O `cron` executa comandos automaticamente em horários programados. É a base de automação em servidores Linux.

### Editar Crontab

```bash
# Editar crontab do usuário atual
crontab -e

# Listar tarefas agendadas
crontab -l

# Editar crontab de outro usuário (root)
sudo crontab -u usuario -e

# Remover todas as tarefas
crontab -r
```

### Formato do Crontab

```
┌───────────── minuto (0-59)
│ ┌───────────── hora (0-23)
│ │ ┌───────────── dia do mês (1-31)
│ │ │ ┌───────────── mês (1-12)
│ │ │ │ ┌───────────── dia da semana (0-7, 0 e 7 = domingo)
│ │ │ │ │
* * * * * comando
```

### Exemplos

```bash
# A cada minuto
* * * * * /scripts/check.sh

# Todo dia às 3h da manhã
0 3 * * * /scripts/backup.sh

# De segunda a sexta às 8h
0 8 * * 1-5 /scripts/relatorio.sh

# A cada 15 minutos
*/15 * * * * /scripts/monitor.sh

# Primeiro dia de cada mês às 6h
0 6 1 * * /scripts/mensal.sh

# Todo domingo às 2h
0 2 * * 0 /scripts/limpeza.sh

# A cada 2 horas
0 */2 * * * /scripts/sync.sh
```

### Atalhos Especiais

| Atalho | Equivalente | Significado |
|--------|-------------|-------------|
| `@reboot` | | Ao iniciar o sistema |
| `@hourly` | `0 * * * *` | A cada hora |
| `@daily` | `0 0 * * *` | Todo dia à meia-noite |
| `@weekly` | `0 0 * * 0` | Todo domingo |
| `@monthly` | `0 0 1 * *` | Primeiro dia do mês |
| `@yearly` | `0 0 1 1 *` | 1 de janeiro |

### Dicas Importantes

```bash
# Redirecionar saída para log
0 3 * * * /scripts/backup.sh >> /var/log/backup.log 2>&1

# Descartar saída (evitar emails do cron)
*/5 * * * * /scripts/check.sh > /dev/null 2>&1

# Usar PATH completo (cron tem PATH limitado)
0 3 * * * /usr/bin/python3 /scripts/relatorio.py
```

### Cron do Sistema

```bash
# Diretórios para scripts do sistema
/etc/cron.d/          # Arquivos crontab individuais
/etc/cron.daily/      # Executados diariamente
/etc/cron.hourly/     # Executados a cada hora
/etc/cron.weekly/     # Executados semanalmente
/etc/cron.monthly/    # Executados mensalmente
```

Para colocar um script em `/etc/cron.daily/`, basta copiar o script (sem extensão, com permissão de execução).

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
