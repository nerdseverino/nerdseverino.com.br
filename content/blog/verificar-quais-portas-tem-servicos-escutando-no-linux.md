---
title: Verificar quais portas tem servicos escutando no Linux
date: '2022-12-02T20:12:35-03:00'
categories:
  - Dicas
tags:
  - portugues
keywords:
  - network
  - cli
  - linux
  - ports
  - tcp
  - services
  - portas
  - rede
autoThumbnailImage: true
thumbnailImagePosition: top
coverImage: ''
---
<!-- Link comentado para verificação: http://web.mit.edu/rhel-doc/4/RH-DOCS/rhel-sg-pt_br-4/s1-server-ports.html -->

<p align="center">
<img src="/images/uploads/network_logo1.png" width="240" title="Network logo">
</p>

- - -

5.8. Verificando Quais Portas estão Escutando

Após configurar os serviços de rede, é importante atentar para quais portas estão escutando as interfaces de rede do sistema. Quaisquer portas abertas podem ser evidências de uma intrusão.

Há duas formas básicas de listar as portas que estão escutando a rede. A menos confiável é questionar a lista da rede ao digitar comandos como netstat -an ou lsof -i. Este método é menos confiável já que estes programas não conectam à máquina pela rede, mas checam o que está sendo executado no sistema. Por esta razão, estas aplicações são alvos frequentes de substituição por atacantes. Desta maneira, os crackers tentam cobrir seus passos se abrirem portas de rede não autorizadas.

Uma forma mais confiável de listar quais portas estão escutando a rede é usar um scanner de portas como o nmap.

O comando a seguir, submetido em um console, determina quais portas estão escutando conexões FTP pela rede:

```
nmap -sT -O localhost
```

O output deste comando se parece com o seguinte:

```
Starting nmap 3.55 ( http://www.insecure.org/nmap/ ) at 2004-09-24 13:49 EDT
Interesting ports on localhost.localdomain (127.0.0.1):
(The 1653 ports scanned but not shown below are in state: closed)
PORT      STATE SERVICE
22/tcp    open  ssh
25/tcp    open  smtp
111/tcp   open  rpcbind
113/tcp   open  auth
631/tcp   open  ipp
834/tcp   open  unknown
2601/tcp  open  zebra
32774/tcp open  sometimes-rpc11
Device type: general purpose
Running: Linux 2.4.X|2.5.X|2.6.X
OS details: Linux 2.5.25 - 2.6.3 or Gentoo 1.2 Linux 2.4.19 rc1-rc7)
Uptime 12.857 days (since Sat Sep 11 17:16:20 2004)
 
Nmap run completed -- 1 IP address (1 host up) scanned in 5.190 seconds
```

Este output mostra que o sistema está rodando o portmap devido à presença do serviço sunrpc. No entanto, também há um serviço misterioso na porta 834. Para verificar se a porta está associada à lista oficial de serviços conhecidos, digite:

```
cat /etc/services | grep 834
```

Este comando não retorna nenhum output. Isto indica que enquanto a porta está no intervalo reservado (de 0 a 1023) e requer acesso root para abrir, não está associada a um serviço conhecido.

Em seguida, verifique as informações sobre a porta usando netstat ou lsof. Para verificar a porta 834 usando netstat, use o seguinte comando:

```
netstat -anp | grep 834
```

O comando retorna o seguinte output:

```
tcp   0    0 0.0.0.0:834    0.0.0.0:*   LISTEN   653/ypbind
```

A presença da porta aberta em netstat afirma que um cracker que abrir clandestinamente uma porta num sistema hackeado provavelmente não permitirá que esta seja revelada através deste comando. A opção \[p] também revela o id do processo (PID) do serviço que abriu a porta. Neste caso, a porta aberta pertence ao ypbind (NIS), que é um serviço RPC administrado juntamente ao serviço portmap.

O comando lsof revela informações similares já que é capaz de ligar portas abertas a serviços:

```
lsof -i | grep 834
```

Veja abaixo a parte relevante do output deste comando:

```
ypbind      653        0    7u  IPv4       1319                 TCP *:834 (LISTEN)
ypbind      655        0    7u  IPv4       1319                 TCP *:834 (LISTEN)
ypbind      656        0    7u  IPv4       1319                 TCP *:834 (LISTEN)
ypbind      657        0    7u  IPv4       1319                 TCP *:834 (LISTEN)
```

Estas ferramentas podem revelar muitas informações sobre o estado dos serviços rodando em uma máquina. Estas ferramentas são flexíveis e podem prover uma riqueza de informações sobre os serviços e configurações da rede. Portanto, recomendamos fortemente que você consulte as páginas man do lsof, netstat, nmap e services.

- - -
