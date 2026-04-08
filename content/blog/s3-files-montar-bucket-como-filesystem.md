---
title: "S3 Files: Agora Você Pode Montar um Bucket S3 como Filesystem"
date: 2026-04-08T08:40:00-03:00
categories:
  - AWS
  - SRE
tags:
  - aws
  - s3
  - storage
  - filesystem
  - nfs
  - efs
keywords:
  - s3 files
  - amazon s3 filesystem
  - montar s3
  - nfs s3
  - s3 mount ec2
  - object storage filesystem
autoThumbnailImage: false
thumbnailImagePosition: top
---

A AWS acabou de lançar o S3 Files — e se você é SRE, isso muda bastante coisa. Em resumo: agora você pode montar um bucket S3 como filesystem NFS em qualquer compute da AWS. Sem gambiarras, sem FUSE, sem sync manual.

<!--more-->

## O que mudou

Até agora, S3 era object storage puro. Você não podia abrir um arquivo, editar uma linha e salvar — precisava baixar o objeto inteiro, modificar e fazer upload de volta. Isso forçava arquiteturas com EFS ou FSx quando a aplicação precisava de acesso a arquivos.

O S3 Files elimina essa barreira. Ele cria um filesystem NFS v4.1+ em cima do seu bucket S3 general purpose. Você monta no EC2, ECS, EKS ou Lambda e trabalha com comandos normais: `cat`, `vim`, `cp`, `rm`, `grep` — tudo funciona.

Por baixo dos panos, o S3 Files usa o EFS como camada de performance. Dados acessados frequentemente ficam em storage de alta performance (~1ms de latência). Dados frios são servidos direto do S3. Ele faz pre-fetching inteligente e suporta byte-range reads — só transfere os bytes que você pediu.

## Sistemas suportados

- **EC2** — mount direto via NFS
- **ECS** — containers no Fargate ou EC2
- **EKS** — pods Kubernetes
- **Lambda** — funções serverless

Basicamente, qualquer compute AWS. Precisa do pacote `amazon-efs-utils` atualizado (já vem nas AMIs oficiais).

## Como funciona na prática

```bash
# Criar o filesystem (console, CLI ou IaC)
aws s3-files create-file-system --bucket meu-bucket

# Criar mount target na VPC
aws s3-files create-mount-target --file-system-id fs-0abc123 --subnet-id subnet-xyz

# Montar no EC2
sudo mkdir /mnt/s3data
sudo mount -t s3files fs-0abc123:/ /mnt/s3data

# Pronto — é um filesystem normal
echo "teste" > /mnt/s3data/hello.txt
ls -la /mnt/s3data/
cat /mnt/s3data/hello.txt
```

Alterações no filesystem aparecem no bucket S3 em minutos. Alterações feitas direto no S3 (via API, console) aparecem no filesystem em segundos.

## Onde isso muda o jogo para SRE

### 1. Logs e configs compartilhados

Antes: você precisava de EFS ou sync manual para compartilhar configs entre instâncias de um ASG. Agora:

```bash
# Todas as instâncias montam o mesmo bucket
mount -t s3files fs-xxx:/ /etc/app-config

# Atualizou a config no S3? Todas as instâncias veem
aws s3 cp novo-config.yml s3://meu-bucket/app/config.yml
```

### 2. Troubleshooting sem SSH

Container morreu e você precisa dos logs? Se o container escrevia em um path montado via S3 Files, os logs já estão no S3:

```bash
# Logs persistem mesmo depois do container morrer
aws s3 ls s3://meu-bucket/logs/app/
aws s3 cp s3://meu-bucket/logs/app/error.log -
```

### 3. Scripts e ferramentas compartilhadas

Time de SRE com scripts espalhados em 50 instâncias? Centraliza no S3:

```bash
# Monta em todas as instâncias via user-data
mount -t s3files fs-xxx:/tools /opt/sre-tools

# Atualizou o script? Todas as instâncias pegam
/opt/sre-tools/check-health.sh
```

### 4. Backup e disaster recovery

Dados que antes precisavam de cron + `aws s3 sync` agora são nativamente persistidos:

```bash
# Aplicação escreve normalmente no filesystem
app --data-dir /mnt/s3data/app-data/

# Dados já estão no S3 com toda a durabilidade (11 noves)
# Versionamento do S3 funciona normalmente
```

### 5. Lambda com acesso a arquivos grandes

Lambda sempre teve limitação de storage (512MB em /tmp, 10GB com EFS). Agora com S3 Files, uma função Lambda pode acessar terabytes de dados como filesystem:

```python
def handler(event, context):
    # S3 Files montado em /mnt/data
    with open('/mnt/data/dataset.csv') as f:
        for line in f:
            process(line)
```

## O que observar

- **Consistência**: NFS close-to-open. Se dois processos escrevem no mesmo arquivo, o último a fechar ganha. Não é POSIX strict locking.
- **Latência de sync**: filesystem → S3 leva minutos. S3 → filesystem leva segundos. Não é tempo real.
- **Custo**: você paga pelo storage no filesystem (dados quentes) + requests S3 durante sync + storage S3 normal. Precisa fazer conta.
- **Permissões**: usa POSIX (UID/GID) no filesystem + IAM para acesso ao mount target. Duas camadas de controle.
- **Criptografia**: TLS 1.3 em trânsito, SSE-S3 ou KMS em repouso. Sem opção de desligar.

## S3 Files vs EFS vs FSx — quando usar cada um

| Cenário | Use |
|---------|-----|
| Dados já estão no S3 e precisa acesso como filesystem | **S3 Files** |
| Filesystem compartilhado puro (sem S3) | **EFS** |
| Migração de NAS on-premises | **FSx for NetApp ONTAP** |
| HPC / GPU clusters | **FSx for Lustre** |
| Workloads Windows | **FSx for Windows** |

A regra é simples: se o dado nasce ou vive no S3, use S3 Files. Se o dado nasce no filesystem e não precisa do S3, use EFS.

## Disponibilidade e preço

Disponível em todas as regiões comerciais da AWS. Preço baseado em:
- Storage no filesystem (dados quentes)
- Operações de escrita e leitura de arquivos pequenos
- Requests S3 durante sincronização

Detalhes na [página de preços do S3](https://aws.amazon.com/s3/pricing/).

---

*Depois de mais de uma década explicando a diferença entre object storage e filesystem, a AWS decidiu borrar essa linha. Para SREs, isso significa menos arquiteturas complexas, menos syncs manuais e menos motivos para manter EFS só porque a aplicação precisa de `open()` e `write()`. Vale testar.*
