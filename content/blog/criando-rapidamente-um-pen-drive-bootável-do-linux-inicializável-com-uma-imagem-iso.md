---
title: >-
  Criando rapidamente um pen-drive bootável do Linux (inicializável) com uma
  imagem ISO
date: '2022-12-13T12:35:34-03:00'
categories:
  - Dicas
tags:
  - english
  - portugues
keywords:
  - iso
  - boot
  - pendrive
  - linux
  - windows
  - ''
autoThumbnailImage: true
thumbnailImagePosition: top
coverImage: ''
---
<p align="center">

<img src="/images/uploads/multiboot-logo2.png" width="240" title="Iso boot logo">

</p>

No Linux, diferente do Windows, você não precisa de nenhum programa adicional para essa tarefa. O dd (nativo do Linux) faz isso tranquilamente.

Primeiro abra o Terminal (Se for Ubuntu ou Linux Mint: Menu Principal / Acessórios / Terminal), e vire root. Entre na pasta onde está a imagem iso e digite o comando:

```
dd if=linuxmint-13-mate-dvd-32bit.iso of=/dev/sdc oflag=direct bs=1048576
```

Trocando** linuxmint-13-mate-dvd-32bit.iso** pelo nome da imagem que você quer jogar no pen-drive e **/dev/sdc** pelo caminho do seu pen-drive. Se você não sabe o caminho do seu pen-drive, o comando **fdisk -l** (também como root) lista todos os dispositivos de armazenamento que estão conectados ao computador no momento. O **df -h** é um pouco mais "humano" e mais fácil de entender, pode ser uma outra opção.

**_Você precisa ter certeza que o dispositivo é o correto, pois você perderá todos os dados do dispositivo informado._** Lembre-se que você deverá informar o dispositivo (Ex.: /dev/sdc) e não a partição (Ex.: /dev/sdc1). Geralmente o /dev/sda é o HD principal.
