---
title: 4 - Gerenciamento de Arquivos e Permissões
date: 2026-02-02T04:22:00.000Z
categories:
  - Curso
tags:
  - curso
  - linux
  - permissoes
  - chmod
  - chown
keywords:
  - linux
  - permissoes
  - chmod
  - chown
  - acl
autoThumbnailImage: false
thumbnailImagePosition: top
coverImage: /images/uploads/9cbzwmsn.png
---

## Sistema de Permissões do Linux

Linux é um sistema multiusuário. Cada arquivo e diretório tem permissões que controlam quem pode ler, escrever ou executar.

### Estrutura de Permissões

```bash
ls -l arquivo.txt
-rw-r--r-- 1 usuario grupo 1024 fev  2 10:30 arquivo.txt
│││││││││  │ │       │     │    │
│││││││││  │ │       │     │    └─ nome do arquivo
│││││││││  │ │       │     └────── data de modificação
│││││││││  │ │       └──────────── tamanho (bytes)
│││││││││  │ └──────────────────── grupo
│││││││││  └────────────────────── dono
││││││││└─ outros (r--)
│││││└──── grupo (r--)
││└────── dono (rw-)
│└─────── tipo (- = arquivo, d = diretório, l = link)
```

### Tipos de Permissões

- **r (read)**: Ler conteúdo
  - Arquivo: Ver conteúdo
  - Diretório: Listar arquivos
  
- **w (write)**: Escrever/modificar
  - Arquivo: Editar conteúdo
  - Diretório: Criar/deletar arquivos
  
- **x (execute)**: Executar
  - Arquivo: Executar como programa
  - Diretório: Entrar no diretório (cd)

### Representação Numérica (Octal)

```
r = 4
w = 2
x = 1

rwx = 4+2+1 = 7
rw- = 4+2+0 = 6
r-x = 4+0+1 = 5
r-- = 4+0+0 = 4
```

## chmod - Alterar Permissões

### Modo Simbólico

```bash
# Adicionar permissão de execução para o dono
chmod u+x script.sh

# Remover permissão de escrita do grupo
chmod g-w arquivo.txt

# Adicionar leitura para outros
chmod o+r documento.txt

# Adicionar execução para todos
chmod a+x programa

# Múltiplas alterações
chmod u+x,g-w,o-r arquivo.txt

# Definir permissões exatas
chmod u=rwx,g=rx,o=r arquivo.txt
```

**Símbolos:**
- `u` = user (dono)
- `g` = group (grupo)
- `o` = others (outros)
- `a` = all (todos)

### Modo Numérico (Octal)

```bash
# rwxr-xr-x (755)
chmod 755 script.sh

# rw-r--r-- (644)
chmod 644 arquivo.txt

# rwx------ (700)
chmod 700 privado.sh

# rw-rw-r-- (664)
chmod 664 compartilhado.txt

# Recursivo em diretório
chmod -R 755 /var/www/html
```

### Permissões Comuns

```bash
# Arquivos de texto/documentos
chmod 644 documento.txt    # rw-r--r--

# Scripts executáveis
chmod 755 script.sh        # rwxr-xr-x

# Arquivos privados
chmod 600 senha.txt        # rw-------

# Diretórios públicos
chmod 755 /var/www         # rwxr-xr-x

# Diretórios privados
chmod 700 ~/.ssh           # rwx------
```

## chown - Alterar Proprietário

```bash
# Alterar dono
sudo chown usuario arquivo.txt

# Alterar dono e grupo
sudo chown usuario:grupo arquivo.txt

# Apenas grupo
sudo chown :grupo arquivo.txt

# Recursivo
sudo chown -R usuario:grupo /var/www

# Copiar permissões de outro arquivo
sudo chown --reference=arquivo1.txt arquivo2.txt
```

## chgrp - Alterar Grupo

```bash
# Alterar grupo
sudo chgrp grupo arquivo.txt

# Recursivo
sudo chgrp -R www-data /var/www
```

## Permissões Especiais

### SUID (Set User ID) - 4000

Executa com permissões do dono do arquivo:

```bash
# Adicionar SUID
chmod u+s programa
chmod 4755 programa

# Exemplo: passwd precisa de SUID para alterar /etc/shadow
ls -l /usr/bin/passwd
-rwsr-xr-x 1 root root 68208 /usr/bin/passwd
```

### SGID (Set Group ID) - 2000

Arquivos criados herdam o grupo do diretório:

```bash
# Adicionar SGID
chmod g+s diretorio/
chmod 2755 diretorio/

# Útil para diretórios compartilhados
sudo mkdir /compartilhado
sudo chgrp equipe /compartilhado
sudo chmod 2775 /compartilhado
```

### Sticky Bit - 1000

Apenas o dono pode deletar seus arquivos:

```bash
# Adicionar Sticky Bit
chmod +t diretorio/
chmod 1777 diretorio/

# Exemplo: /tmp tem sticky bit
ls -ld /tmp
drwxrwxrwt 20 root root 4096 /tmp
```

## umask - Permissões Padrão

Define permissões padrão para novos arquivos:

```bash
# Ver umask atual
umask
# Saída: 0022

# Definir umask
umask 0027

# Cálculo:
# Arquivos: 666 - umask = permissões
# 666 - 022 = 644 (rw-r--r--)

# Diretórios: 777 - umask = permissões
# 777 - 022 = 755 (rwxr-xr-x)
```

**Umasks comuns:**
- `0022`: Arquivos 644, Diretórios 755 (padrão)
- `0027`: Arquivos 640, Diretórios 750 (mais restritivo)
- `0077`: Arquivos 600, Diretórios 700 (privado)

## ACL - Access Control Lists

Permissões mais granulares que o sistema tradicional:

### Instalar ACL

```bash
# Ubuntu/Debian
sudo apt install acl

# Fedora
sudo dnf install acl
```

### Comandos ACL

```bash
# Ver ACL
getfacl arquivo.txt

# Dar permissão específica para usuário
setfacl -m u:usuario:rwx arquivo.txt

# Dar permissão para grupo
setfacl -m g:grupo:rx arquivo.txt

# Remover ACL de usuário
setfacl -x u:usuario arquivo.txt

# Remover todas ACLs
setfacl -b arquivo.txt

# ACL recursiva
setfacl -R -m u:usuario:rwx diretorio/

# ACL padrão (para novos arquivos)
setfacl -d -m u:usuario:rwx diretorio/
```

### Exemplo Prático

```bash
# Permitir que 'maria' leia arquivo do 'joao'
sudo setfacl -m u:maria:r /home/joao/documento.txt

# Verificar
getfacl /home/joao/documento.txt
# user::rw-
# user:maria:r--
# group::r--
# mask::r--
# other::---
```

## Atributos de Arquivos

### lsattr - Listar Atributos

```bash
lsattr arquivo.txt
```

### chattr - Alterar Atributos

```bash
# Imutável (não pode ser modificado/deletado, nem por root)
sudo chattr +i arquivo.txt

# Remover imutável
sudo chattr -i arquivo.txt

# Append only (só pode adicionar conteúdo)
sudo chattr +a log.txt

# Não atualizar tempo de acesso
sudo chattr +A arquivo.txt
```

**Atributos úteis:**
- `i`: Imutável
- `a`: Append only
- `A`: No atime update
- `c`: Comprimido automaticamente
- `s`: Secure deletion (sobrescreve com zeros)

## Links

### Hard Links

Múltiplos nomes para o mesmo inode:

```bash
# Criar hard link
ln arquivo.txt link_arquivo.txt

# Verificar inodes
ls -li arquivo.txt link_arquivo.txt
# 1234567 -rw-r--r-- 2 usuario grupo 1024 arquivo.txt
# 1234567 -rw-r--r-- 2 usuario grupo 1024 link_arquivo.txt
```

**Características:**
- Mesmo inode
- Deletar um não afeta o outro
- Não funciona entre filesystems
- Não funciona com diretórios

### Symbolic Links (Symlinks)

Atalhos para arquivos/diretórios:

```bash
# Criar symlink
ln -s /caminho/completo/arquivo.txt link

# Symlink para diretório
ln -s /var/www/html ~/www

# Verificar
ls -l link
# lrwxrwxrwx 1 usuario grupo 24 link -> /caminho/completo/arquivo.txt

# Atualizar symlink
ln -sf novo_destino link

# Remover symlink
rm link  # Não afeta o arquivo original
```

**Características:**
- Arquivo separado apontando para outro
- Funciona entre filesystems
- Funciona com diretórios
- Se o original for deletado, o link fica "quebrado"

## Busca Avançada com find

### Por Permissões

```bash
# Arquivos com permissão 777
find /home -perm 777

# Arquivos com SUID
find / -perm -4000 2>/dev/null

# Arquivos com SGID
find / -perm -2000 2>/dev/null

# Arquivos world-writable
find / -perm -002 2>/dev/null
```

### Por Proprietário

```bash
# Arquivos do usuário
find /home -user usuario

# Arquivos do grupo
find /var -group www-data

# Arquivos sem dono (órfãos)
find / -nouser 2>/dev/null

# Arquivos sem grupo
find / -nogroup 2>/dev/null
```

### Executar Ações

```bash
# Alterar permissões em massa
find /var/www -type f -exec chmod 644 {} \;
find /var/www -type d -exec chmod 755 {} \;

# Alterar dono
find /var/www -exec chown www-data:www-data {} \;

# Deletar arquivos antigos
find /tmp -type f -mtime +7 -delete
```

## Casos de Uso Práticos

### 1. Configurar Servidor Web

```bash
# Estrutura típica
sudo chown -R www-data:www-data /var/www/html
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;
```

### 2. Diretório Compartilhado

```bash
# Criar grupo
sudo groupadd equipe

# Adicionar usuários ao grupo
sudo usermod -aG equipe usuario1
sudo usermod -aG equipe usuario2

# Configurar diretório
sudo mkdir /compartilhado
sudo chgrp equipe /compartilhado
sudo chmod 2775 /compartilhado  # SGID + rwxrwxr-x
```

### 3. Chaves SSH

```bash
# Permissões corretas para SSH
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 644 ~/.ssh/authorized_keys
chmod 644 ~/.ssh/known_hosts
```

### 4. Scripts Executáveis

```bash
# Tornar script executável
chmod +x script.sh

# Executar
./script.sh
```

### 5. Backup com Permissões

```bash
# Copiar preservando permissões
cp -p arquivo.txt backup/

# Tar preserva permissões por padrão
tar czf backup.tar.gz /dados

# Rsync preservando tudo
rsync -av /origem/ /destino/
```

## Troubleshooting de Permissões

### Problema: Permission Denied

```bash
# Verificar permissões
ls -l arquivo.txt

# Verificar dono
ls -l arquivo.txt

# Verificar grupos do usuário
groups

# Verificar ACL
getfacl arquivo.txt
```

### Problema: Script não executa

```bash
# Adicionar permissão de execução
chmod +x script.sh

# Verificar shebang
head -1 script.sh
# Deve ter: #!/bin/bash
```

### Problema: Não consigo deletar arquivo

```bash
# Verificar atributos
lsattr arquivo.txt

# Remover imutável
sudo chattr -i arquivo.txt

# Verificar permissões do diretório
ls -ld diretorio/
```

## Boas Práticas de Segurança

### 1. Princípio do Menor Privilégio

```bash
# Evite 777
# Use permissões específicas
chmod 755 diretorio/  # Não 777
chmod 644 arquivo.txt # Não 666
```

### 2. Proteja Arquivos Sensíveis

```bash
# Arquivos de configuração
chmod 600 ~/.ssh/id_rsa
chmod 600 /etc/shadow

# Logs sensíveis
chmod 640 /var/log/auth.log
```

### 3. Audite Permissões Perigosas

```bash
# Encontrar arquivos SUID (potencial risco)
sudo find / -perm -4000 -ls 2>/dev/null

# Arquivos world-writable
sudo find / -perm -002 -type f -ls 2>/dev/null
```

### 4. Use Grupos Apropriadamente

```bash
# Não adicione usuários ao grupo root
# Crie grupos específicos
sudo groupadd developers
sudo usermod -aG developers usuario
```

## Comandos de Referência Rápida

```bash
# Ver permissões
ls -l arquivo.txt

# Alterar permissões (simbólico)
chmod u+x arquivo.txt

# Alterar permissões (numérico)
chmod 644 arquivo.txt

# Alterar dono
sudo chown usuario:grupo arquivo.txt

# Alterar grupo
sudo chgrp grupo arquivo.txt

# Ver ACL
getfacl arquivo.txt

# Definir ACL
setfacl -m u:usuario:rwx arquivo.txt

# Ver atributos
lsattr arquivo.txt

# Definir atributos
sudo chattr +i arquivo.txt

# Hard link
ln arquivo.txt link.txt

# Symbolic link
ln -s /caminho/arquivo.txt link

# Buscar por permissões
find / -perm 777
```

## Exercícios Práticos

### Exercício 1: Permissões Básicas

```bash
# 1. Crie um arquivo
touch teste.txt

# 2. Defina permissões 644
chmod 644 teste.txt

# 3. Verifique
ls -l teste.txt

# 4. Torne executável
chmod +x teste.txt

# 5. Remova execução de outros
chmod o-x teste.txt
```

### Exercício 2: Diretório Compartilhado

```bash
# 1. Crie diretório
mkdir compartilhado

# 2. Defina SGID
chmod 2775 compartilhado

# 3. Crie arquivo dentro
touch compartilhado/arquivo.txt

# 4. Verifique grupo herdado
ls -l compartilhado/arquivo.txt
```

### Exercício 3: Links

```bash
# 1. Crie arquivo
echo "conteúdo" > original.txt

# 2. Crie hard link
ln original.txt hardlink.txt

# 3. Crie symlink
ln -s original.txt symlink.txt

# 4. Compare inodes
ls -li original.txt hardlink.txt symlink.txt

# 5. Delete original e veja diferença
rm original.txt
cat hardlink.txt  # Funciona
cat symlink.txt   # Erro: link quebrado
```

## Recursos Adicionais

### Documentação

```bash
man chmod
man chown
man setfacl
man chattr
```

### Links Úteis

- [Linux File Permissions Explained](https://www.linux.com/training-tutorials/understanding-linux-file-permissions/)
- [ACL Tutorial](https://wiki.archlinux.org/title/Access_Control_Lists)

---

**Próximo capítulo**: 5 - Gerenciamento de Pacotes e Software

**Capítulo anterior**: [3 - Comandos de Terminal](https://www.nerdseverino.com.br/2024/03/09/3-comandos-de-terminal-e-navega%C3%A7%C3%A3o-de-diret%C3%B3rios/)
