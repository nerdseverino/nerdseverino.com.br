---
title: 'Linux: File System Hierarchy'
date: '2023-01-20T17:35:11-03:00'
categories:
  - Dicas
tags:
  - portugues
keywords:
  - linux
  - file
  - system
  - Ubuntu
  - Amazon
  - software
  - livre
  - free
autoThumbnailImage: true
thumbnailImagePosition: top
coverImage: /images/uploads/file-system-hierarchy-standard-fhs.jpg
---
O FSH (File System Hierarchy) é a estrutura de diretórios utilizada pelo sistema operacional Linux. Ele é composto por uma série de diretórios e arquivos organizados de maneira lógica, que permitem que os usuários e o sistema acessem e gerenciem os arquivos de maneira eficiente.

A raiz do FSH é representada pelo diretório '/', a partir do qual todos os outros diretórios e arquivos são acessados. Abaixo estão alguns dos principais diretórios do FSH:

```
/bin: Contém os comandos básicos e binários essenciais do sistema, como ls, cp, mv, etc.
/sbin: Contém os comandos administrativos e binários essenciais do sistema, como init, shutdown, etc.
/etc: Contém arquivos de configuração do sistema, como arquivos de inicialização, arquivos de senhas, etc.
/usr: Contém programas, bibliotecas e documentação instalados pelo usuário.
/var: Contém arquivos que mudam com o tempo, como arquivos de log, arquivos temporários, etc.
/home: Contém os diretórios pessoais de cada usuário do sistema.
/root: Diretório pessoal do usuário root (administrador do sistema).
/dev: Contém arquivos de dispositivos, como discos rígidos, unidades de CD-ROM, etc.
/proc: Contém informações sobre os processos em execução no sistema, como uso de memória, etc.
/tmp: Contém arquivos temporários criados pelo sistema e pelos usuários.\
```

É importante notar que esta estrutura de diretórios pode variar dependendo da distribuição Linux utilizada, mas os diretórios listados acima são comuns em todas as distribuições. Conhecer a estrutura de diretórios do FSH é fundamental para entender como o sistema operacional Linux funciona e para gerenciar arquivos e pastas de maneira eficiente.
