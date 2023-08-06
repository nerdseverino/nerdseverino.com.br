---
title: Exportar Logs do Container na Ec2 para o AWS CloudWatch
date: '2022-12-01T16:17:49-03:00'
categories:
  - Dicas
tags:
  - portugues
keywords:
  - AWS
  - Docker
  - EC2
  - CloudWatch
  - Linux
  - CLI
  - Instance
  - Container
  - Amazon
autoThumbnailImage: true
thumbnailImagePosition: top
thumbnailImage: ''
coverImage: ''
---
<p align="center">

<img src="/images/uploads/amazon-cloudwatch-logo-made-1.webp" width="240" title="Amazon Cloudwatch logo">

</p>

Imaginamos que você tem sua instância do EC2 executando contêineres docker. Você provavelmente está usando docker-compose para orquestração de contêiner (eu sei que existem soluções melhores).

Neste Dica, mostrarei o que você precisa fazer para armazenar logs de contêiner do Docker no serviço AWS Cloud Watch Logs.

O que é preciso fazer:

* Criar um Log Group
* Criar uma IAM Role
* Configurar serviço Docker

## Criar um Log Group:

No  AWS Console, acesse o CloudWatch e localize Logs/Log groups. Em seguida, crie um novo Log Group. Uma dica é usar algo relacionado ao nome do software ou algo como Ec2-instanceid-docker:

![](/images/uploads/1_vxye3__lh3adbgeme3icyg.webp)

## Criar uma IAM Role

Tem mais de uma maneira de dar acesso à instância do EC2 para serviço AWS, mas usar uma função IAM é o jeito mais fácil.

![Criar Nova Função IAM](/images/uploads/1__urdj5mmv3sroua-aeueoa.webp)

Crie uma nova police com o conteúdo abaixo:

```
{

    "Version": "2012-10-17",

    "Statement": [

        {

            "Action": [

                "logs:CreateLogStream",

                "logs:PutLogEvents",

                "logs:CreateLogGroup"

            ],

            "Effect": "Allow",

            "Resource": "*"

        }

    ]

}
```

Depois anexe essa função a EC2 que possui os containers.

## Configurar serviço Docker

## 

Agora vem a parte mais mão na massa dessa dica, como ativar o pluguin do docker para o AWSLOGS:

O que vamos fazer é dizer ao docker daemon para falar com o AWS CloudWatch Logs. Primeiro edite /etc/docker/daemon.json para que tenha esta informação:

```
{
  "log-driver": "awslogs",
  "log-opts": {
    "awslogs-region": "eu-central-1",
    "awslogs-group" : "my-service-dev"
  }
}
```

Em seguida reinicie o docker:

`systemctl restart docker.service` ou `service docker restart`

A última etapa é opcional. Se você não fizer isso no docker-compose, verá fluxos de log com nomes baseados no ID do contêiner.

```version: '3.1'
services:

  mongo:
    logging:
      options:
        awslogs-stream: mongo
    image: mongo
    restart: always
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: example

  mongo-express:
    logging:
      options:
        awslogs-stream: mongo-express
    image: mongo-express
    restart: always
    ports:
      - 8081:8081
    environment:
      ME_CONFIG_MONGODB_ADMINUSERNAME: root
      ME_CONFIG_MONGODB_ADMINPASSWORD: example
```

Por hoje é isso pessoal espero que seja útil pra alguém e se quiser pode deixar um comentário aqui em baixo :D
