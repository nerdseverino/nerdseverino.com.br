---
title: 3 - Comandos de Terminal e Navegação de Diretórios
date: 2024-03-09T14:06:38.443Z
categories: 
  - Curso
tags:
  - mini
  - curso
  - linux
  - terminal
  - bash
keywords:
  - mini
  - curso
  - linux
  - terminal
  - comandos
autoThumbnailImage: false
thumbnailImagePosition: top
coverImage: /images/uploads/9cbzwmsn.png
---

## Por Que Usar o Terminal?

O terminal (ou shell) é uma das ferramentas mais poderosas do Linux. Enquanto interfaces gráficas são limitadas ao que os desenvolvedores implementaram, o terminal oferece:

- **Automação**: Scripts para tarefas repetitivas
- **Eficiência**: Comandos mais rápidos que cliques
- **Poder**: Acesso a todas as funcionalidades do sistema
- **Administração remota**: SSH para gerenciar servidores
- **Troubleshooting**: Diagnóstico preciso de problemas

## Estrutura do Sistema de Arquivos Linux

Diferente do Windows (C:\, D:\), Linux usa uma estrutura hierárquica única:

```
/                    (raiz - root)
├── bin/            (binários essenciais)
├── boot/           (arquivos de boot)
├── dev/            (dispositivos)
├── etc/            (configurações do sistema)
├── home/           (diretórios dos usuários)
│   ├── usuario1/
│   └── usuario2/
├── lib/            (bibliotecas compartilhadas)
├── media/          (mídias removíveis)
├── mnt/            (pontos de montagem temporários)
├── opt/            (software opcional)
├── proc/           (informações de processos)
├── root/           (home do root)
├── run/            (dados de runtime)
├── sbin/           (binários de sistema)
├── srv/            (dados de serviços)
├── sys/            (informações do kernel)
├── tmp/            (arquivos temporários)
├── usr/            (aplicações de usuário)
└── var/            (dados variáveis - logs, cache)
```

### Diretórios Importantes

- **`/home/usuario`**: Seus arquivos pessoais (equivalente a C:\Users\usuario)
- **`/etc`**: Configurações do sistema
- **`/var/log`**: Logs do sistema
- **`/tmp`**: Arquivos temporários (limpo no reboot)
- **`/usr/bin`**: Programas instalados
- **`/opt`**: Software de terceiros

## Navegação Básica

### pwd - Print Working Directory

Mostra onde você está:

```bash
pwd
# Saída: /home/usuario/Documentos
```

### ls - List

Lista arquivos e diretórios:

```bash
# Listagem simples
ls

# Listagem detalhada
ls -l

# Mostrar arquivos ocultos
ls -a

# Listagem detalhada com arquivos ocultos
ls -la

# Tamanhos legíveis (KB, MB, GB)
ls -lh

# Ordenar por data de modificação
ls -lt

# Ordenar por tamanho
ls -lS

# Listagem recursiva
ls -R
```

**Saída de `ls -lh`:**
```
drwxr-xr-x 2 usuario grupo 4.0K fev  2 10:30 Documentos
-rw-r--r-- 1 usuario grupo 1.5M fev  1 15:20 foto.jpg
-rwxr-xr-x 1 usuario grupo  12K jan 30 09:15 script.sh
```

**Entendendo as permissões:**
- `d`: diretório
- `rwx`: read, write, execute
- Primeiro grupo: permissões do dono
- Segundo grupo: permissões do grupo
- Terceiro grupo: permissões de outros

### cd - Change Directory

Navega entre diretórios:

```bash
# Ir para um diretório
cd /home/usuario/Documentos

# Voltar ao diretório anterior
cd -

# Ir para o diretório home
cd
# ou
cd ~

# Subir um nível
cd ..

# Subir dois níveis
cd ../..

# Ir para a raiz
cd /
```

**Atalhos úteis:**
- `~`: Diretório home (`/home/usuario`)
- `.`: Diretório atual
- `..`: Diretório pai
- `-`: Diretório anterior

### Autocompletar com TAB

O TAB é seu melhor amigo:

```bash
# Digite parte do nome e pressione TAB
cd Doc[TAB]
# Completa para: cd Documentos/

# Pressione TAB duas vezes para ver opções
cd D[TAB][TAB]
# Mostra: Desktop/ Documentos/ Downloads/
```

## Manipulação de Diretórios

### mkdir - Make Directory

Cria diretórios:

```bash
# Criar um diretório
mkdir projetos

# Criar múltiplos diretórios
mkdir projeto1 projeto2 projeto3

# Criar estrutura de diretórios
mkdir -p projetos/web/frontend/src

# Criar com permissões específicas
mkdir -m 755 publico
```

### rmdir - Remove Directory

Remove diretórios **vazios**:

```bash
# Remover diretório vazio
rmdir pasta_vazia

# Remover estrutura de diretórios vazios
rmdir -p projetos/teste/vazio
```

### rm - Remove

Remove arquivos e diretórios:

```bash
# Remover arquivo
rm arquivo.txt

# Remover múltiplos arquivos
rm arquivo1.txt arquivo2.txt

# Remover diretório e conteúdo (CUIDADO!)
rm -r pasta/

# Remover forçado (sem confirmação)
rm -f arquivo.txt

# Remover diretório forçado e recursivo
rm -rf pasta/

# Remover com confirmação
rm -i arquivo.txt

# Remover arquivos com padrão
rm *.txt
rm backup_*
```

**⚠️ ATENÇÃO**: `rm -rf` é permanente! Não há lixeira no terminal.

## Manipulação de Arquivos

### cp - Copy

Copia arquivos e diretórios:

```bash
# Copiar arquivo
cp origem.txt destino.txt

# Copiar para outro diretório
cp arquivo.txt /home/usuario/Documentos/

# Copiar múltiplos arquivos
cp arquivo1.txt arquivo2.txt /destino/

# Copiar diretório recursivamente
cp -r pasta_origem/ pasta_destino/

# Copiar preservando atributos
cp -p arquivo.txt backup.txt

# Copiar com confirmação antes de sobrescrever
cp -i arquivo.txt destino.txt

# Copiar mostrando progresso
cp -v arquivo.txt destino.txt
```

### mv - Move

Move ou renomeia arquivos:

```bash
# Renomear arquivo
mv nome_antigo.txt nome_novo.txt

# Mover arquivo
mv arquivo.txt /home/usuario/Documentos/

# Mover múltiplos arquivos
mv arquivo1.txt arquivo2.txt /destino/

# Mover diretório
mv pasta_antiga/ pasta_nova/

# Mover com confirmação
mv -i arquivo.txt destino.txt

# Mover sem sobrescrever
mv -n arquivo.txt destino.txt
```

### touch - Create File

Cria arquivos vazios ou atualiza timestamp:

```bash
# Criar arquivo vazio
touch arquivo.txt

# Criar múltiplos arquivos
touch arquivo1.txt arquivo2.txt arquivo3.txt

# Atualizar timestamp de arquivo existente
touch arquivo_existente.txt
```

## Visualização de Arquivos

### cat - Concatenate

Exibe conteúdo de arquivos:

```bash
# Mostrar conteúdo
cat arquivo.txt

# Mostrar múltiplos arquivos
cat arquivo1.txt arquivo2.txt

# Mostrar com números de linha
cat -n arquivo.txt

# Concatenar arquivos em um novo
cat arquivo1.txt arquivo2.txt > combinado.txt
```

### less - Pager

Visualiza arquivos grandes (navegável):

```bash
less arquivo.txt

# Navegação dentro do less:
# Espaço: próxima página
# b: página anterior
# /texto: buscar texto
# n: próxima ocorrência
# q: sair
```

### head - First Lines

Mostra primeiras linhas:

```bash
# Primeiras 10 linhas (padrão)
head arquivo.txt

# Primeiras 20 linhas
head -n 20 arquivo.txt

# Primeiros 100 bytes
head -c 100 arquivo.txt
```

### tail - Last Lines

Mostra últimas linhas:

```bash
# Últimas 10 linhas (padrão)
tail arquivo.txt

# Últimas 50 linhas
tail -n 50 arquivo.txt

# Acompanhar arquivo em tempo real (logs)
tail -f /var/log/syslog

# Acompanhar com número de linhas
tail -f -n 100 /var/log/syslog
```

## Busca e Localização

### find - Find Files

Busca arquivos no sistema:

```bash
# Buscar por nome
find /home -name "arquivo.txt"

# Buscar ignorando maiúsculas/minúsculas
find /home -iname "arquivo.txt"

# Buscar por extensão
find /home -name "*.pdf"

# Buscar arquivos modificados nos últimos 7 dias
find /home -mtime -7

# Buscar arquivos maiores que 100MB
find /home -size +100M

# Buscar e executar comando
find /tmp -name "*.tmp" -delete

# Buscar diretórios
find /home -type d -name "projetos"

# Buscar arquivos
find /home -type f -name "*.log"
```

### locate - Fast Find

Busca rápida usando banco de dados:

```bash
# Buscar arquivo
locate arquivo.txt

# Atualizar banco de dados
sudo updatedb

# Buscar ignorando maiúsculas
locate -i arquivo.txt

# Limitar resultados
locate -n 10 arquivo.txt
```

### which - Find Command

Localiza executáveis:

```bash
# Onde está o comando?
which python
# Saída: /usr/bin/python

which ls
# Saída: /usr/bin/ls
```

### whereis - Locate Binary

Localiza binário, fonte e manual:

```bash
whereis python
# Saída: python: /usr/bin/python /usr/lib/python3.10 /usr/share/man/man1/python.1.gz
```

## Atalhos de Teclado Essenciais

### Navegação na Linha

- **Ctrl + A**: Início da linha
- **Ctrl + E**: Fim da linha
- **Ctrl + U**: Apagar do cursor até o início
- **Ctrl + K**: Apagar do cursor até o fim
- **Ctrl + W**: Apagar palavra anterior
- **Alt + B**: Voltar uma palavra
- **Alt + F**: Avançar uma palavra

### Controle de Processos

- **Ctrl + C**: Interromper comando atual
- **Ctrl + Z**: Suspender comando (background)
- **Ctrl + D**: Logout / EOF
- **Ctrl + L**: Limpar tela (igual a `clear`)

### Histórico de Comandos

- **Seta ↑/↓**: Navegar no histórico
- **Ctrl + R**: Buscar no histórico (reverse search)
- **!!**: Repetir último comando
- **!$**: Último argumento do comando anterior

```bash
# Exemplo de !$
mkdir /tmp/teste
cd !$
# Executa: cd /tmp/teste
```

## Histórico de Comandos

### history - Command History

```bash
# Ver histórico
history

# Ver últimos 20 comandos
history 20

# Executar comando do histórico
!123  # Executa comando número 123

# Executar último comando que começou com 'git'
!git

# Buscar no histórico
Ctrl + R
# Digite parte do comando
```

### Limpar Histórico

```bash
# Limpar histórico da sessão
history -c

# Limpar arquivo de histórico
rm ~/.bash_history
```

## Wildcards (Curingas)

Padrões para matching de arquivos:

```bash
# * - qualquer sequência de caracteres
ls *.txt          # Todos arquivos .txt
rm backup_*       # Todos arquivos começando com backup_

# ? - um único caractere
ls arquivo?.txt   # arquivo1.txt, arquivo2.txt, etc.

# [] - conjunto de caracteres
ls arquivo[123].txt    # arquivo1.txt, arquivo2.txt, arquivo3.txt
ls [A-Z]*.txt          # Arquivos começando com maiúscula

# {} - expansão de chaves
mkdir projeto_{web,mobile,api}
# Cria: projeto_web, projeto_mobile, projeto_api

cp arquivo.txt{,.bak}
# Cria: arquivo.txt.bak (backup)
```

## Redirecionamento e Pipes

### Redirecionamento de Saída

```bash
# Sobrescrever arquivo
ls > lista.txt

# Adicionar ao arquivo
ls >> lista.txt

# Redirecionar erro
comando 2> erros.txt

# Redirecionar saída e erro
comando > saida.txt 2>&1

# Descartar saída
comando > /dev/null
```

### Pipes (|)

Conecta saída de um comando à entrada de outro:

```bash
# Listar e filtrar
ls -l | grep ".txt"

# Contar linhas
cat arquivo.txt | wc -l

# Ordenar e remover duplicatas
cat lista.txt | sort | uniq

# Ver processos e filtrar
ps aux | grep python

# Logs em tempo real filtrados
tail -f /var/log/syslog | grep error
```

## Comandos de Informação

### file - File Type

Identifica tipo de arquivo:

```bash
file documento.pdf
# Saída: documento.pdf: PDF document, version 1.4

file imagem.jpg
# Saída: imagem.jpg: JPEG image data
```

### du - Disk Usage

Uso de disco:

```bash
# Tamanho do diretório atual
du -sh .

# Tamanho de cada subdiretório
du -h --max-depth=1

# Top 10 maiores diretórios
du -h | sort -rh | head -10
```

### df - Disk Free

Espaço livre em disco:

```bash
# Espaço em disco
df -h

# Apenas sistema de arquivos local
df -h -x tmpfs -x devtmpfs
```

### wc - Word Count

Conta linhas, palavras, caracteres:

```bash
# Contar linhas
wc -l arquivo.txt

# Contar palavras
wc -w arquivo.txt

# Contar caracteres
wc -c arquivo.txt

# Tudo junto
wc arquivo.txt
# Saída: linhas palavras bytes arquivo.txt
```

## Dicas Práticas de Produção

### 1. Sempre use TAB para autocompletar
Evita erros de digitação e economiza tempo.

### 2. Use `cd -` para alternar entre diretórios
```bash
cd /var/log
cd /etc
cd -  # Volta para /var/log
```

### 3. Combine comandos com `&&` e `||`
```bash
# Executa segundo comando apenas se primeiro suceder
mkdir projeto && cd projeto

# Executa segundo comando apenas se primeiro falhar
cd /diretorio || echo "Diretório não existe"
```

### 4. Use aliases para comandos frequentes
```bash
# Adicione ao ~/.bashrc
alias ll='ls -lah'
alias ..='cd ..'
alias ...='cd ../..'
```

### 5. Cuidado com espaços em nomes
```bash
# Use aspas ou escape
cd "Meus Documentos"
cd Meus\ Documentos
```

## Exercícios Práticos

### Exercício 1: Navegação Básica
```bash
# 1. Vá para seu diretório home
cd ~

# 2. Crie estrutura de diretórios
mkdir -p projetos/web/frontend projetos/web/backend

# 3. Navegue até frontend
cd projetos/web/frontend

# 4. Volte para projetos
cd ../..

# 5. Liste tudo recursivamente
ls -R
```

### Exercício 2: Manipulação de Arquivos
```bash
# 1. Crie arquivos de teste
touch arquivo1.txt arquivo2.txt arquivo3.txt

# 2. Copie todos para backup
mkdir backup
cp *.txt backup/

# 3. Renomeie arquivo1
mv arquivo1.txt primeiro.txt

# 4. Liste com detalhes
ls -lh
```

### Exercício 3: Busca e Filtros
```bash
# 1. Encontre todos arquivos .txt no home
find ~ -name "*.txt" -type f

# 2. Liste processos do Python
ps aux | grep python

# 3. Conte quantos arquivos .txt existem
find ~ -name "*.txt" -type f | wc -l
```

## Recursos Adicionais

### Documentação

```bash
# Manual de um comando
man ls

# Ajuda rápida
ls --help

# Informações sobre comando
info ls
```

### Cheat Sheets Online

- [Linux Command Line Cheat Sheet](https://cheatography.com/davechild/cheat-sheets/linux-command-line/)
- [Bash Scripting Cheat Sheet](https://devhints.io/bash)

### Prática Interativa

- [OverTheWire: Bandit](https://overthewire.org/wargames/bandit/) - Aprenda comandos jogando
- [Linux Journey](https://linuxjourney.com/) - Tutorial interativo

---

**Próximo capítulo**: Gerenciamento de Arquivos e Permissões (em breve)

**Capítulo anterior**: [2 - Instalação](https://www.nerdseverino.com.br/2023/05/09/2-instala%C3%A7%C3%A3o/)
