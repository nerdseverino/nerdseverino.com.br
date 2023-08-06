---
title: Como ver o Crontab de todos os usuários Rapidamente
date: '2022-12-09T08:33:53-03:00'
categories:
  - Dicas
tags:
  - portugues
keywords:
  - cron
  - linux
  - crontab
  - cli
  - agendamento
autoThumbnailImage: true
thumbnailImagePosition: top
coverImage: ''
---
<p align="center">

<img src="/images/uploads/crontab.png" width="240" title="Cron pi logo">

</p>

Nesta dica mostro como com um comando simples podemos ver crontab de todos os usuários. Tanto no Linux, como MAC OS X

Copie e cole no terminal:

```
for user in $(cut -f1 -d: /etc/passwd); do echo $user; sudo crontab -u $user -l; done
```

espero que seja útil. :D

Fico por aqui e até a próxima!
