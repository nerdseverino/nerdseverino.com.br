---
title: Permissões especiais no Linux
date: '2022-12-15T12:37:06-03:00'
categories:
  - Dicas
tags:
  - portugues
keywords:
  - Linux. cli. permissions
autoThumbnailImage: false
thumbnailImagePosition: top
coverImage: /images/uploads/chartt.jpg
---


Fonte: <https://www.vivaolinux.com.br/artigo/Atributos-de-arquivos-no-Linux>

vou falar um pouco de "atributos de arquivos", além de alterar as permissões de um arquivo, um usuário também pode fazer o mesmo com seus atributos. Os atributos de um arquivo são alterados com um comando:

```
chattr [atributo] [arquivo]
```

E listados com os comando:

```
lsattr \[arquivo]
```

Os atributos permitem o aumento da proteção e da segurança que serão destinadas a um arquivo ou diretório. Por exemplo, o atributo:

"i" define o arquivo como imutável, o que impede que seja alterado, excluído, renomeado ou vinculado, uma excelente maneira de protegê-lo. Já o atributo:

"s" faz com que o conteúdo de um arquivo seja eliminado completamente do disco quando o arquivo for excluído. Isso assegura que o conteúdo não possa ser acessado depois que o arquivo for excluído.

A seguir veremos quais são os atributos que podem ser alterados.

TIPOS DE ATRIBUTOS

Bom, esses são os tipos de atributos que podem ser alterados:

\[a] - Abre o arquivo só no modo de anexação, pode ser configurado somente pelo "root";

\[c] - O arquivo é automaticamente compactado no disco pelo kernel;

\[i] - O arquivo não pode ser alterado, excluído ou renomeado, nenhum vínculo pode ser criado para ele e nenhum dado pode ser escrito nele;

\[s] - Quando o arquivo é excluído, seus blocos são zerados e gravados posteriormente no disco;

\[S] - Quando o arquivo é modificado, as alterações são gravadas simultaneamente no disco;

\[u] - Quando o arquivo é excluído, seu conteúdo é salvo.

Mais opções de flags de comandos você pode ver com o comando:

```
man chattr
```

Com o comando chmod, um atributo é adicionado com +(mais) e removido com -(menos).

EXEMPLOS DE USO DE ATRIBUTOS

Aqui está um exemplo simples de como usar os atributos, primeiro crie um arquivo com o comando:

```
touch teste.txt
```

Agora vamos colocar os atributos com o comando:

```
chattr +u teste.txt
```

e para visualizar o atributo basta você dar o comando:

```
lsattr teste.txt
```

Repare que o arquivo teste.txt ficou assim:

```
-u----------- teste.txt
```

Você deu a este arquivo a opção de que, quando ele for excluído, irá salvar o seu conteúdo.

Agora vamos tirar esse atributo com o comando:

```
chattr -u teste.txt
```

Depois novamente dê o comando:

```
lsattr teste.txt
```

Repare que o arquivo está assim agora:

```
------------- teste.txt
```

O atributo "u" foi removido...

Treine bastante e veja todos os comandos possíveis.

CONCLUSÃO

É isso aí galera, o Linux faz jus a sua segurança com o comando chattr. Você pode dar e retirar atributos e juntamente com o comando chmod, seu PC irá se tornar uma "fortaleza"!

Isso é claro, se usando corretamente os comandos.

Bom, é isso aí.
