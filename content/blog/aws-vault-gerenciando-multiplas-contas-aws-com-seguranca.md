---
title: "aws-vault: Gerenciando Múltiplas Contas AWS com Segurança"
description: |
  Se você trabalha com mais de uma conta AWS — e se é SRE ou DevOps, provavelmente trabalha com várias — já deve ter sentido o medo de rodar um terraform destroy na conta errada. O aws-vault resolve esse problema e mais alguns.

  🔗 https://nerdseverino.com.br/blog/aws-vault-gerenciando-multiplas-contas-aws-com-seguranca/
date: 2026-03-23T19:21:00-03:00
categories:
  - DevOps
  - AWS
tags:
  - aws
  - segurança
  - cli
  - sre
  - iam
keywords:
  - aws-vault
  - múltiplas contas aws
  - credenciais aws
  - assume role
  - sso
  - segurança aws
autoThumbnailImage: false
thumbnailImagePosition: top
---

Se você trabalha com mais de uma conta AWS — e se é SRE ou DevOps, provavelmente trabalha com várias — já deve ter sentido o medo de rodar um `terraform destroy` na conta errada. O `aws-vault` resolve esse problema e mais alguns.

<!--more-->

## O problema

O jeito padrão de configurar credenciais AWS é jogar access keys no `~/.aws/credentials`. Funciona, mas tem problemas sérios:

- As chaves ficam **em texto puro** no disco
- É fácil confundir qual perfil está ativo
- Não há rotação automática
- Se alguém acessa seu home, tem suas chaves

Quando você gerencia 5, 10, 20 contas de clientes diferentes, isso vira uma bomba-relógio.

## O que é o aws-vault

O [aws-vault](https://github.com/99designs/aws-vault) é uma ferramenta que armazena suas credenciais AWS no keychain do sistema operacional (ou em backends criptografados) e gera credenciais temporárias via STS quando você precisa.

Na prática:
- Suas access keys **nunca ficam em texto puro**
- Cada sessão usa **credenciais temporárias** com expiração
- Você assume roles em contas diferentes de forma simples
- Funciona com SSO, MFA e assume role

## Instalação

### Linux

```bash
# Download do binário
curl -L -o aws-vault https://github.com/99designs/aws-vault/releases/latest/download/aws-vault-linux-amd64
chmod +x aws-vault
sudo mv aws-vault /usr/local/bin/

# ARM (Raspberry Pi, Graviton, etc.)
curl -L -o aws-vault https://github.com/99designs/aws-vault/releases/latest/download/aws-vault-linux-arm64
chmod +x aws-vault
sudo mv aws-vault /usr/local/bin/
```

### macOS

```bash
brew install aws-vault
```

### Verificar

```bash
aws-vault --version
```

## Configuração Inicial

### Passo 1: Escolher o backend

No Linux sem interface gráfica (servidores, Termux, WSL), use o backend de arquivo criptografado:

```bash
export AWS_VAULT_BACKEND=file
```

Adicione ao seu `~/.bashrc` ou `~/.zshrc` para persistir:

```bash
echo 'export AWS_VAULT_BACKEND=file' >> ~/.bashrc
```

Na primeira vez que adicionar credenciais, ele vai pedir uma senha para criptografar o vault.

### Passo 2: Adicionar credenciais

```bash
aws-vault add meu-perfil-pessoal
```

Ele vai pedir a Access Key ID e Secret Access Key. As chaves são armazenadas criptografadas — não no `~/.aws/credentials`.

### Passo 3: Configurar perfis com assume role

Aqui é onde a mágica acontece. No `~/.aws/config`, você define perfis que assumem roles em outras contas:

```ini
# Conta principal (onde estão as chaves)
[profile meu-perfil-pessoal]
region = us-east-1
mfa_serial = arn:aws:iam::123456789012:mfa/meu-usuario

# Conta de desenvolvimento
[profile projeto-alpha-dev]
source_profile = meu-perfil-pessoal
role_arn = arn:aws:iam::111111111111:role/SRE-CrossAccountRole
region = us-east-1

# Conta de staging
[profile projeto-alpha-staging]
source_profile = meu-perfil-pessoal
role_arn = arn:aws:iam::222222222222:role/SRE-CrossAccountRole
region = us-east-1

# Conta de produção
[profile projeto-alpha-prod]
source_profile = meu-perfil-pessoal
role_arn = arn:aws:iam::333333333333:role/SRE-CrossAccountRole
region = sa-east-1
mfa_serial = arn:aws:iam::123456789012:mfa/meu-usuario

# Outro cliente
[profile projeto-beta-prod]
source_profile = meu-perfil-pessoal
role_arn = arn:aws:iam::444444444444:role/AdminRole
region = us-east-1
```

## Uso no Dia a Dia

### Executar comandos em uma conta específica

```bash
# Listar instâncias EC2 na conta de dev
aws-vault exec projeto-alpha-dev -- aws ec2 describe-instances

# Verificar quem eu sou nessa conta
aws-vault exec projeto-alpha-prod -- aws sts get-caller-identity
```

O `aws-vault exec` faz o assume role, gera credenciais temporárias e injeta como variáveis de ambiente no subprocesso. Quando o comando termina, as credenciais somem.

### Abrir uma shell inteira na conta

```bash
aws-vault exec projeto-alpha-dev
```

Isso abre um subshell com as credenciais da conta. Tudo que você rodar ali dentro (aws cli, terraform, ansible) vai usar aquela conta. Para sair, `exit`.

### Abrir o console AWS no navegador

```bash
aws-vault login projeto-alpha-prod
```

Abre o console web da AWS já autenticado na conta certa. Muito útil para verificações rápidas.

### Listar perfis e sessões ativas

```bash
aws-vault list
```

Saída:

```text
Profile                  Credentials              Sessions
=======                  ===========              ========
meu-perfil-pessoal       meu-perfil-pessoal       -
projeto-alpha-dev        meu-perfil-pessoal       sts.AssumeRole:47m32s
projeto-alpha-staging    meu-perfil-pessoal       -
projeto-alpha-prod       meu-perfil-pessoal       -
projeto-beta-prod        meu-perfil-pessoal       -
```

## Com MFA

Se a conta exige MFA (e deveria), o aws-vault pede o token automaticamente:

```bash
$ aws-vault exec projeto-alpha-prod -- aws s3 ls
Enter token for arn:aws:iam::123456789012:mfa/meu-usuario: 123456
```

Ele cacheia a sessão MFA, então você não precisa digitar o token a cada comando dentro da janela de validade (geralmente 1 hora).

## Com AWS SSO (Identity Center)

Se sua organização usa AWS SSO:

```ini
[profile empresa-sso]
sso_start_url = https://minha-empresa.awsapps.com/start
sso_region = us-east-1
sso_account_id = 123456789012
sso_role_name = AdministratorAccess
region = us-east-1
```

```bash
# Login SSO
aws-vault login empresa-sso

# Executar comandos
aws-vault exec empresa-sso -- aws s3 ls
```

## Dicas Práticas

### 1. Alias para contas frequentes

No `~/.bashrc`:

```bash
alias aws-dev='aws-vault exec projeto-alpha-dev --'
alias aws-stg='aws-vault exec projeto-alpha-staging --'
alias aws-prd='aws-vault exec projeto-alpha-prod --'
```

Uso:

```bash
aws-dev aws ec2 describe-instances
aws-prd aws s3 ls
```

### 2. Duração da sessão

Por padrão, as credenciais temporárias duram 1 hora. Para ajustar:

```ini
[profile projeto-alpha-dev]
source_profile = meu-perfil-pessoal
role_arn = arn:aws:iam::111111111111:role/SRE-CrossAccountRole
duration_seconds = 3600
```

O máximo depende da configuração da role na conta destino (até 12 horas).

### 3. Usar com Terraform

```bash
aws-vault exec projeto-alpha-dev -- terraform plan
aws-vault exec projeto-alpha-dev -- terraform apply
```

Ou abra uma shell e trabalhe normalmente:

```bash
aws-vault exec projeto-alpha-dev
terraform init
terraform plan
terraform apply
exit  # sai da sessão
```

### 4. Usar com scripts

```bash
#!/bin/bash
# deploy.sh - Deploy para staging e produção

echo "=== Deploy Staging ==="
aws-vault exec projeto-alpha-staging -- ./deploy-to-ecs.sh

echo "=== Testes de Smoke ==="
aws-vault exec projeto-alpha-staging -- ./smoke-tests.sh

read -p "Deploy para produção? (y/n) " confirm
if [ "$confirm" = "y" ]; then
    echo "=== Deploy Produção ==="
    aws-vault exec projeto-alpha-prod -- ./deploy-to-ecs.sh
fi
```

### 5. Prompt do terminal com conta ativa

Adicione ao `~/.bashrc` para saber em qual conta você está:

```bash
aws_prompt() {
    if [ -n "$AWS_VAULT" ]; then
        echo " ☁️ $AWS_VAULT"
    fi
}
PS1='$(aws_prompt)\u@\h:\w\$ '
```

Resultado:

```text
 ☁️ projeto-alpha-prod fabricio@deck:~$
```

Isso evita aquele momento de pânico: "em qual conta eu estou mesmo?"

## O que NÃO fazer

### ❌ Nunca exporte credenciais permanentes

```bash
# NÃO FAÇA ISSO
export AWS_ACCESS_KEY_ID=AKIA...
export AWS_SECRET_ACCESS_KEY=wJalr...
```

Se você precisa de variáveis de ambiente, use:

```bash
# Isso gera credenciais temporárias
eval $(aws-vault exec meu-perfil -- env | grep AWS)
```

### ❌ Nunca commite o ~/.aws/credentials

Adicione ao `.gitignore` global:

```bash
echo '.aws/credentials' >> ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
```

### ❌ Nunca use a mesma access key para tudo

Uma key por finalidade. Se uma vazar, você revoga só aquela.

## Troubleshooting

### "NoCredentialProviders"

```text
NoCredentialProviders: no valid providers in chain
```

Verifique se o `source_profile` no `~/.aws/config` bate com o nome usado no `aws-vault add`.

### "AccessDenied ao assumir role"

```text
An error occurred (AccessDenied) when calling the AssumeRole operation
```

Verifique:
1. A role existe na conta destino
2. A trust policy da role permite seu usuário
3. O `role_arn` está correto no config

### "Token expirado"

```text
ExpiredToken: The security token included in the request is expired
```

Saia do subshell e entre novamente:

```bash
exit
aws-vault exec projeto-alpha-dev
```

## Comparação: com e sem aws-vault

| Aspecto | Sem aws-vault | Com aws-vault |
|---------|--------------|---------------|
| Armazenamento | Texto puro em ~/.aws/credentials | Criptografado no keychain/vault |
| Credenciais | Permanentes | Temporárias (STS) |
| Troca de conta | Editar variáveis ou --profile | `aws-vault exec perfil` |
| MFA | Manual a cada chamada | Cacheado por sessão |
| Risco de vazamento | Alto | Baixo |
| Auditoria | Difícil (mesma key sempre) | Fácil (sessões distintas no CloudTrail) |

## Conclusão

O `aws-vault` é uma daquelas ferramentas que depois que você começa a usar, não entende como vivia sem. O investimento de configuração é de 15 minutos e o retorno é:

- **Segurança**: credenciais nunca ficam expostas em texto puro
- **Praticidade**: trocar entre contas é um comando
- **Auditoria**: cada sessão aparece separada no CloudTrail
- **Tranquilidade**: saber exatamente em qual conta você está antes de rodar qualquer coisa

Se você gerencia múltiplas contas AWS, pare de usar `~/.aws/credentials` em texto puro. Seu eu do futuro agradece.

---

**Links úteis:**
- [aws-vault no GitHub](https://github.com/99designs/aws-vault)
- [Documentação AWS - AssumeRole](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html)
- [AWS SSO / Identity Center](https://aws.amazon.com/iam/identity-center/)
