---
title: 3 - Comandos de terminal e navegação de diretórios
date: 2024-03-09T14:06:38.443Z
categories: Dicas
tags:
  - mini
  - curso
  - linux
  - software
  - livre
keywords:
  - mini
  - curso
  - linux
  - software
  - livre
autoThumbnailImage: false
thumbnailImagePosition: top
coverImage: /images/uploads/9cbzwmsn.png
---
O terminal é uma ferramenta poderosa no Linux, permitindo que você acesse e manipule arquivos, configure o sistema e execute diversas tarefas. Dominar os comandos básicos de navegação de diretórios é fundamental para usar o terminal com eficiência.

## Navegando por Diretórios

`cd: Muda para o diretório especificado. Ex: cd Downloads`\
`pwd: Mostra o diretório de trabalho atual.`\
`ls: Lista os arquivos e subdiretórios do diretório atual.`\
`..: Retorna ao diretório pai.`\
`~: Refere-se ao diretório home do usuário.`\
`TAB: Autocompleta nomes de arquivos e diretórios.`

## Manipulando Diretórios

`mkdir: Cria um novo diretório. Ex: mkdir nova_pasta`\
`rmdir: Remove um diretório vazio. Ex: rmdir pasta_vazia`\
`mv: Move ou renomeia arquivos e diretórios. Ex: mv arquivo.txt novo_nome.txt`\
`cp: Copia arquivos e diretórios. Ex: cp arquivo.txt /home/usuario/Documentos`\
`rm: Remove arquivos. Cuidado: Use com cautela, pois a exclusão é permanente. Ex: rm arquivo.txt`

## Opções Úteis

`-l: Com ls, exibe detalhes adicionais sobre os arquivos..`\
`-a: Com ls, mostra arquivos ocultos.`\
`-r: ** ls, inverte a ordem da listagem.`\
`-h: Com ls, converte tamanhos de arquivos em unidades legíveis.`

## Use atalhos de teclado para agilizar a navegação:

`Ctrl + L: Limpa a tela.`\
`Ctrl + A: Move para o início da linha.`\
`Ctrl + E: Move para o final da linha.`\
`Ctrl + C: Interrompe um comando.`

#### Utilize o histórico de comandos para acessar comandos usados anteriormente:

`Cima/Baixo: Navega pelo histórico.
Ctrl + R: Busca por um comando no histórico.`

#### Combine comandos para realizar tarefas complexas:

`ls | grep "palavra": Lista arquivos que contêm a palavra "palavra"`\
`cd $(find . -name "arquivo.txt"): Move para o diretório que contém o arquivo "arquivo.txt".`

## Recursos Adicionais

Consulte a documentação dos comandos: **man comando.**\
Ou no navegador em **[Linux man pages](https://linux.die.net/man/)**