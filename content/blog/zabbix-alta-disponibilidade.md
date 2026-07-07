---
title: "Alta Disponibilidade no Zabbix: Server e Proxy"
date: 2026-07-10T08:00:00-03:00
description: |
  Se o Zabbix cai, quem monitora o Zabbix?

  A API e as configurações avançadas do Zabbix permitem ir muito além do básico.

  🔗 https://nerdseverino.com.br/blog/zabbix-alta-disponibilidade/

  #Zabbix #Monitoramento #SRE #DevOps
categories:
  - SRE
  - Monitoramento
tags:
  - zabbix
  - monitoramento
  - sre
  - serie-zabbix-na-pratica
keywords:
  - zabbix ha alta disponibilidade failover
autoThumbnailImage: false
thumbnailImagePosition: top
---

Zabbix sem HA é single point of failure. Se o server cai, você fica cego exatamente quando mais precisa de visibilidade.

<!--more-->

## Tópicos cobertos

HA nativo do Zabbix 6.0+ (active-standby), configuração de nós HA, failover automático, database replication (PostgreSQL streaming, MySQL replication), proxy como buffer (dados não se perdem se server cai), sizing para HA, monitoramento do próprio Zabbix (meta-monitoring), backup e disaster recovery

*(Post completo em desenvolvimento. Será expandido antes da publicação.)*

---

*Este post faz parte da série Zabbix na Prática. Acompanhe pela tag serie-zabbix-na-pratica.*
