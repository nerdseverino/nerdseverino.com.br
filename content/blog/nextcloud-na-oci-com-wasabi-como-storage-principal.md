---
title: Nextcloud na OCI com Wasabi como Storage principal.
date: '2022-02-26T03:28:24-03:00'
categories:
  - Dicas
tags:
  - oci
  - nextcloud
  - docker
  - bucket
  - wasabi
  - instance
keywords:
  - oci
  - nextcloud
  - docker
  - bucket
  - wasabi
  - instance
autoThumbnailImage: true
thumbnailImagePosition: top
coverImage: ''
---
<p align="center">

<img src="/images/uploads/oracle_cloud_logo-600x350-1.jpg" width="240" title="Oracle Logo">

</p>

<p align="center">

<img src="/images/uploads/nextcloud-logo.wine.png" width="240" title="Nextcloud logo">

</p>

<p align="center">

<img src="/images/uploads/wasabi_cloud_storage.png" width="240" title="Wasabi storage logo">

</p>

Pessoal, fiz alguns testes aqui e queria compartilhar o resultado com vocês:

**_\- Provedor: Oracle Cloud - Free Tier_**

```Infraestrutura
    2 VMs de computação baseadas em AMD com 1/8 OCPU\*\* e 1 GB de memória cada.
    4 núcleos Ampere A1 baseados em Arm e 24 GB de memória utilizáveis como uma VM ou até 4 VMs.
    Armazenamento de volumes em 2 blocos, total de 200 GB.
    10 GB de Armazenamento de Objetos.
    10 GB de Armazenamento de Arquivos.
    Balanceador de Carga de Rede Flexível.
    Transferência de Dados de Saída: 10 TB por mês.
    Registro em log: 10 GB por mês.
```

Basicamente o que usei foi: 

\- 1X - VMs de computação baseadas em AMD com 1/8 OCPU__ e 1 GB de memória.

* Trial account wasabi (após o trial cobrado $6 por 1 Tb)
* DNS no cloudflare

Para esse post a intenção é falar mais sobre as características dele do que como fazer, o setup rolou com containers em **Docker**, usando a imagem do **nextcloud** com apache, banco em container usando **mariadb** e um proxy reverso chamado **Nginx proxy manager** (<https://nginxproxymanager.com/guide/#quick-setup>)

Para usar o bucket wasabi como storage principal uma vez que a máquia na OCI tinha apenas 50 Gb de espaço foi necessário criar um arquivo chamado storage.config.php que vai dentro da pasta config do Nextcloud.

```
<?php
$CONFIG = array (
'objectstore' => array(
        'class' => '\\OC\\Files\\ObjectStore\\S3',
        'arguments' => array(
                'bucket' => 'my-nextcloud-bucket',
                'autocreate' => true,
                'key'    => 'BYQLD4LZGEXAMPLE',
                'secret' => 'dycOcoq6R9YwTVEXAMPLE',
                'hostname' => 's3.us-west-1.wasabisys.com',
                'region' => 'us-west-1',
                'port' => 443,
                'use_ssl' => true,
                'use_path_style'=>true
        ),
),
);
```

Vou deixar aqui o tutorial que eu usei para criar o arquivo como referência: <https://anto.online/guides/how-to-install-nextcloud-using-wasabi-s3-as-primary-storage/>

Depois disso foi necessário apenas subir o docker-compose file e liberar as portas para acesso externo e fazer os apontamentos no DNS para o nome que eu queria usar no navegador. :D
