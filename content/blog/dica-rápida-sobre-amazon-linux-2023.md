---
title: "Dica Rápida sobre Amazon Linux 2023 "
date: 2024-10-09T16:26:49.115Z
categories: Dicas
tags:
  - "2023"
  - amazon
  - linux
  - software
  - livre
keywords:
  - "2023"
  - amazon
  - linux
  - software
  - livre
autoThumbnailImage: false
thumbnailImagePosition: top
coverImage: /images/uploads/9cbzwmsn.png
---
B﻿om me deparei subindo uma nova EC2 recentemente que a AMI do Amazon Linux 2023 tem algumas diferenças que vou deixar anotado aqui abaixo:

\-﻿ Selinux ativado por padrão - Antes a maquina apenas precisava ser liberada no Security Group da AWS, mas agora com o Selinux ativado ele precisa ser revisado também para conexões de entrada. 

\- C﻿rontab e Rsyslog -  Mesmo sabendo que o SystemD pode gerenciar agendamentos muitas vezes queremos optar pelo bom e velho Cron para isso  é necessário fazer a instalação dos serviço. Junto com ele recomendo o Rsyslog também 

`sudo yum install cronie rsyslog -y`
`sudo systemctl enable crond.service`
`sudo systemctl enable rsyslogd.service`
`sudo systemctl start crond.service`
`sudo systemctl start rsyslogd.service`
`sudo systemctl status crond.service`
`sudo systemctl status rsyslogd.service`

B﻿ônus Track:

#docker-compose (latest version)
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
#Fix permissions after download
chmod +x /usr/local/bin/docker-compose
#Verify success
docker-compose version

P﻿or hoje é só pessoal! :D