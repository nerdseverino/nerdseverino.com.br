---
title: Como reiniciar o serviço docker sem afetar os contêineres em execução
date: 2023-08-11T13:59:40.675Z
categories: Dicas
tags:
  - container
  - docker
  - linux
  - software
  - livre
keywords:
  - container
  - docker
  - linux
  - software
  - livre
autoThumbnailImage: true
thumbnailImagePosition: top
thumbnailImage: ""
coverImage: /images/uploads/docker-logo.png
---
Reinicie o serviço docker sem afetar os contêineres em execução usando a funcionalidade de [Live Restore](https://docs.docker.com/config/containers/live-restore/).
M﻿uito útil para quando você precisa alterar ou mesmo atualizar o binário do Docker no seu sistema operacional. 

P﻿rimeiro, vamos listar os containers em execução: 

**`docker ps`**

```
CONTAINER ID   IMAGE                          COMMAND                  CREATED       STATUS                 PORTS                    NAMES
4c644b887440   archivebox/archivebox:master   "dumb-init -- /app/b…"   2 weeks ago   Up 2 weeks (healthy)   0.0.0.0:8000->8000/tcp   archivebox_archivebox_1
```

Reinicie o serviço do docker.

**`sudo systemctl restart docker`**

Observe que o contêiner em execução também foi reiniciado.

**`docker ps`**

```
CONTAINER ID   IMAGE                          COMMAND                  CREATED              STATUS                        PORTS                    NAMES
46e33e628976   archivebox/archivebox:master   "dumb-init -- /app/b…"   About a minute ago   Up About a minute (healthy)   0.0.0.0:8000->8000/tcp   archivebox_archivebox_1
```

Vamos ativar a funcionalidade de restauração ao vivo.

**`vim  /etc/docker/daemon.json`**

```
{
  "live-restore": true
}
```

Vamos reler as configurações do docker:

**`sudo systemctl reload  docker`**

Agora vamos reiniciar o docker novamente:

**`sudo systemctl restart docker`**

Observe que o contêiner ainda está em execução. O status dele continua e não foi reiniciado. 

**`docker ps`** 

```
CONTAINER ID   IMAGE                          COMMAND                  CREATED         STATUS                   PORTS                    NAMES
46e33e628976   archivebox/archivebox:master   "dumb-init -- /app/b…"   4 minutes ago   Up 4 minutes (healthy)   0.0.0.0:8000->8000/tcp   archivebox_archivebox_1
```

[Ref.](https://sleeplessbeastie.eu/2023/04/12/how-to-restart-docker-service-without-affecting-running-containers/)