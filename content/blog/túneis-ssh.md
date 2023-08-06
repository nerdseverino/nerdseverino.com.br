---
title: Túneis SSH
date: '2022-12-07T09:01:46-03:00'
categories:
  - Dicas
tags:
  - portugues
keywords:
  - tunel
  - ssh
  - linux
  - cli
  - putty
  - windows
  - proxy
autoThumbnailImage: true
thumbnailImagePosition: top
thumbnailImage: ''
coverImage: ''
---
<p align="center">

<img src="/images/uploads/5064908.png" width="240" title="SSH logo">

</p>

Vou reproduzir um post de um blog que não está mais disponível, mas o conteúdo me ajudou bastante na época:

Por: André Stato 15 de fevereiro de 2016 

Usar um túnel ssh pode ser muito útil em várias situações. Uma deles é quando você não quer que seus dados trafeguem em texto puro pela rede Local, desta forma, usa-se um túnel criptografado por onde os dados trafegam.  Por exemplo, uma autenticação em um site WEB, que não está usado ssl, ou seja, os dados serão enviados em texto puro, e qualquer sniffer poderia facilmente capturar.

Outra situação muito interessante é quando existe a necessidade de acessar um serviço qualquer, seja na máquina gateway, ou em um cliente interno, mas não se deseja criar uma regra de DNAT (Destination Nat), que deixará essa porta aberta ao mundo. Por exemplo, se você quer acessar um servidor Mysql que está no gateway de sua empresa, e obviamente deixar o banco aberto na Internet não uma das melhores ideias, dessa forma, o firewall bloqueia conexões vindas de fora, mas não bloqueia conexões internas. Com isso é possível criar uma conexão ssh, e abrir um túnel através da internet para o banco de dados. Ou ainda, se existir a necessidade de acessar um Terminal Service em uma máquina interna, e da mesma forma você não quer deixar uma regra de DNAT encaminhando conexões para dentro da sua rede, a solução seria realmente usar novamente o túnel ssh.

E ainda uma ultima situação, onde você não tem permissão para acessar certo tipo de conteúdo em um determinado local, como por exemplo, revistas, ou até o próprio email. É possível criar um túnel com um servidor ssh, por exemplo, em sua casa, é usa-lo como gateway de saída. Todo trafego estará criptografado, e o proxy ou firewall não conseguirá capturar o dados, e consequentemente, bloqueá-lo.

Enfim, uma ferramenta realmente poderosa, que pode nos auxiliar de várias formas.

## Configurando o Servidor OpenSsh Server

A primeira coisa a ser feita é a instalação do openssh-server. Ele dará o suporte a todas essas formas de conexão. No caso do debian, basta usar o comando “apt-get install openssh-server”, e no caso do RH pode-se executar o comando “yum install openssh-server”.

Lembrando que tanto os repositórios no debian, como no Red Hat devem estar configurados.

O arquivo de configuração do servidor fica em /etc/ssh/sshd_config. Neste arquivo devem-se alterar as configurações conforme a necessidade. Por exemplo, se o local que você está no momento não permite a saída de conexões na porta 22, então obviamente, não será possível acessar o servidor, por isso é interessante alterar a porta para uma porta que seja permitida a saída, como por exemplo, porta 80, 443. E é claro que neste caso, está porta não pode estar sendo usado para outro serviço como http ou https.

Neste arquivo basta procurar pela entrada:

Port 22

Agora basta alterar a porta 22 por uma outra e reiniciar o serviço ssh.

## Criando Túneis ssh – Primeiro Caso

Vamos para o primeiro caso, você tem a necessidade de acessar uma página WEB, mas não quer que esses dados trafeguem em texto puro pela sua rede local. Neste caso especifico, é necessário que tenhamos um servidor ssh instalado na própria máquina.

Usaremos o ssh-server para criar uma ponte entre sua máquina e a maquina remota, na porta 80, e seu browser passará pelo túnel.

Existe duas possibilidade, onde você já tem um servidor ssh instalado em sua máquina, ou existe outro servidor intermediário com o ssh instalado.

Neste segundo caso, será fechada um conexão até este servidor confiável (túnel) e posteriormente a conexão será feita pelo próprio servidor ssh, para a máquina remota.

Vamos ter a seguinte configuração, sua máquina tem um endereço privado qualquer, você deseja acessar www.stato.blog.br , mas deseja que os dados sejam criptografados. O servidor ssh tem o endereço IP 200.0.0.1.

No Linux, basta executar o seguinte comando:

```
ssh –L 1000:www.stato.blog.br:80 usuario@200.0.0.1
```

**Neste caso o que está sendo feito?**

Abre-se uma conexão na porta 22 do endereço 200.0.0.1, e cria-se um túnel da sua máquina até o servidor ssh, onde a porta local é a 1000, com destino até www.stato.blog.br na porta 80. O sintaxe do comando é:

```
ssh –L host_local:portalocal:host_remoto:portaremota usuário@servidor_ssh
```

Como não informamos qual é o endereço local, é utilizado por padrão o localhost.

Note que a criptografia vai até o servidor ssh, depois disso os dados irão trafegar normalmente.

Depois de criado o túnel, basta abrir o browser, e colocar o endereço 127.0.0.1:1000, que a página do site será aberta normalmente.

Vamos ver isso graficamente, para podermos entender melhor:

![exemplo de tunel ssh](/images/uploads/78306760-7b22-441f-88e6-0225056ac9d0.png)

É possível ainda sim, criar a mesma conexão usando no Microsoft Windows, o programa cliente ssh chamado putty. O processo no final é o mesmo, deve-se abrir uma conexão ssh normalmente, e depois de estabelecida, basta ir ao menu, e entrar em “Change Settings…” . Neste menu deverá ser localizado o item Conection->SSH->Tunnels, e então adicionar a porta de origem, o destino já com a porta configurada.

Veja abaixo as figuras. Neste primeiro item vamos estabelecer a conexão normalmente:

![putty para conexão ssh ](/images/uploads/de255a5e-987e-4502-9a59-d8f3291787fb.png)

Já na segunda parte, depois de irmos ao menu change settings dever ser criado o túnel .

E com isso foi fechado à conexão e criado o túnel ssh, basta agora abrir o browser e apontar para o endereço localhost:1000.

O segundo caso que havíamos visto anteriormente

## Criando Túneis SSH – Segundo Caso

O segundo caso não difere muito do primeiro, pois o procedimento é o mesmo, mas o conceito é totalmente diferente.

Para este segundo caso a situação é um pouco diferente, onde você precisa acessar um serviço, seja no servidor ssh, ou em uma máquina interna.

Esse serviço normalmente foi bloqueado pelo firewall iptables (veja mais em http://www.stato.blog.br/wordpress/?page_id=364), ou seja, não existe a porta aberta, pois o firewall está bloqueado.

Imagine a situação do banco de dados rodando no próprio servidor SSH, na porta 3306 (Mysql), ou ainda um cliente interno , onde é necessário acessar o Terminal Service, mas não existe um regra DNAT iptables para redirecionar o trafego. Neste dois caso é possível criar uma conexão até o servidor ssh, e posteriormente criar um túnel para o serviço desejado.

Vamos ver o comando para o servidor de banco de dados mysql:

```
ssh –L 1000:192.168.0.1:3306 usuario@200.0.0.1
```

Neste exemplo acima estamos utilizando as mesmas configurações da situação anterior, ou seja, o servidor ssh continua sendo o 200.0.0.1, mas neste caso , ele também tem o endereço ip 192.168.0.1, ou seja, é um gateway, usando firewall  para bloquear conexões que estejam chegando da internet para o ip publico na porta 3306.

Mas internamente, a rede 192.168.0.0/24 pode acessar o serviço mysql sem problemas ( Não deverá existir regras de firewall bloqueando a rede interna ).

E agora depois de estabelecida a conexão, basta abrir o cliente, e manda-lo conectar em localhost:1000. No cliente mysql bastaria executar :

```
mysql –p 1000 –u root
```

Onde –p é a porta que seja usada para conectar no banco. Como não estamos informando o host, ele tentará conectar em localhost.

A segunda situação, é quando você deseja acessar um servidor interno, como por exemplo, 192.168.0.10, e um serviço que não está sendo tratado pelo firewall com DNAT (O que se diga de passagem, é menos seguro). Podemos então usar o mesmo artificio:

```
ssh –L 1000:192.168.0.10:3389 usuario@200.0.0.1
```

Como podemos ver acima, a sintaxe ainda é a mesma, mas o túnel (-L) tem como destino e porta de destino o servidor 192.168.0.10 e a porta 3389. Abaixo uma figurar poderá esclarecer melhor:



![dnat para outro servidor](/images/uploads/60a6b23c-f7ad-4236-a382-a84c666737d0.png)

No cliente bastaria agora aportar o Remote Desktop, ou Desktop (Linux) para Localhost na porta 1000, veja figura abaixo:

![cliente rdp windows](/images/uploads/8727508f-2ff8-4ea2-a7e3-9bfa3140fd3e.png)



## Criando Túneis ssh – Terceiro Caso

Esse terceiro caso, é o que o pessoal mais gosta no fim das contas, pois com ele é possível burlar muitos proxys e acessar navegação normalmente.

Consiste em criar um conexão ssh, criar o túnel ssh, e então usar a maquina remota como gateway, na realidade como proxy para sock.

O procedimento é o mesmo visto anteriormente em relação à conexão ssh, mas agora muda o comando do túnel , seja para Linux ou para Windows com putty.

No Linux o comando ficará da seguinte forma:

```
ssh –D 1515 usuario@200.0.0.1
```

Esse comando irá criar um conexão ssh, e um SOCKS na porta 1515 da sua máquina, redirecionando todos os pedidos para o servidor ssh.

Agora basta configurar o cliente web ( Firefox, mozilla, etc) , com proxy apontando para socks localhost na porta 1515. Já no Windows, deve-se estabelecer a conexão usando normalmente o putty, mas em SSH->Tunnels, teremos algumas diferenças, vejamos a imagem abaixo:

![configurando putty para proxy dinâmico](/images/uploads/1b500fa0-982b-43ba-9bf8-b444c816aa73.png)

Podemos ver acima, que agora em nosso túnel , iremos usar a porta 1515 (poderia ser qualquer uma , como a 1000 que estávamos usando), e mudamos Destination para Dynamic, já que nosso destino de fato irá variar.

Depois disso, basta configurar o browser para acessar esse SOCKS, veja abaixo a configuração no browser padrão da Microsoft.

Como podemos ver basta configura pra usar o Socks na porta que foi utilizada no túnel ssh, e apontar pra localhost, desta forma a navegação passará pelo proxy sem maiores problemas. Mas tenha atenção no seguinte, se seu proxy, firewall, não permite a saída para a porta 22, basta mudar no servidor ssh, para uma porta que seja permitida, e quando for estabelecer à conexão muda a porta. No putty , basta alterar o valor de port, e no Linux use a opção –p  no comando ssh. Por exemplo, estabelecer uma conexão ssh, onde o servidor está escutando a porta 110 ( A porta originalmente destina a conexões pop):

```
ssh –p 110 –D 1515 usuario@200.0.0.1
```

Desta forma a conexão ssh passará pelo firewall, e depois disso é criar um túnel para trafegar dentro dessa conexão. Como os dados estão criptografados o proxy não conseguirá identificar o que está trafegando. ( Muito cuidado, burlar regras da empresa, pode causar muitos problemas, como demissão por justa causa )

E mais uma vez, espero que aproveitem esse Post.
