---
title: "Detonado: AWS Incident Response Demonstrated"
date: 2026-04-28T16:00:00-03:00
description: |
  Passei na microcredencial AWS Incident Response Demonstrated e documentei tudo.

  Diferente de provas teóricas, aqui você responde a um ataque real no console AWS em 90 minutos:

  🔍 Análise forense com Athena + CloudTrail
  🛡️ Contenção de S3 e EC2 comprometidos
  🔒 Hardening de IMDSv2, Security Groups e RDS
  🧹 Erradicação de backdoors IAM
  📋 Configuração de AWS Config e regras de conformidade

  Documentei a ordem otimizada dos desafios, os erros mais comuns e as dicas que fazem diferença entre passar e reprovar.

  Você já fez alguma microcredencial hands-on da AWS?

  🔗 https://nerdseverino.com.br/blog/detonado-aws-incident-response-demonstrated/

  #AWS #Security #IncidentResponse #SRE #CloudSecurity
categories:
  - AWS
  - SRE
tags:
  - aws
  - segurança
  - incident-response
  - certificação
  - hands-on
keywords:
  - aws incident response
  - microcredencial aws
  - segurança aws
  - cloudtrail
  - athena
  - forense cloud
autoThumbnailImage: false
thumbnailImagePosition: top
---

Passei na microcredencial **AWS Incident Response Demonstrated** e resolvi documentar o processo completo. Diferente de provas teóricas, aqui você executa ações diretamente no console AWS em um ambiente simulado, respondendo a um ataque multivetorial em 90 minutos.

<!--more-->

**Resultado:** APROVADO

**Link:** [AWS Incident Response Demonstrated - Português](https://skillbuilder.aws/learn/UQWKF19DT7/aws-incident-response-demonstrated-portugus)

## O que é essa microcredencial?

A microcredencial **AWS Incident Response Demonstrated** é um exame prático (hands-on) do AWS Skill Builder que valida sua capacidade de responder a um incidente de segurança real na AWS. Diferente de provas teóricas, aqui você executa ações diretamente no console AWS em um ambiente simulado.

O cenário simula um ataque multivetorial à empresa fictícia "AnyCompany Data", onde um engenheiro de segurança em nuvem retorna de férias e descobre que a infraestrutura foi comprometida. Você precisa investigar, conter, eliminar e recuperar o ambiente em 90 minutos.

### O que você vai aprender

- Análise forense de logs com Amazon Athena e CloudTrail
- Contenção de ameaças em S3 (Block Public Access, bucket policies)
- Identificação e remoção de instâncias EC2 comprometidas (crypto mining)
- Hardening de metadados EC2 (IMDSv2)
- Segmentação de rede com Security Groups e Network ACLs
- Erradicação de backdoors IAM
- Configuração de controles de auditoria (AWS Config, CloudTrail)
- Hardening de banco de dados RDS

### Pré-requisitos recomendados

- Conhecimento intermediário de AWS (IAM, EC2, S3, VPC, RDS)
- Familiaridade com o console AWS
- Entendimento básico de resposta a incidentes
- Curso "AWS Cloud Quest: Security" (recomendado, não obrigatório)

## Antes de começar: regras de ouro

1. **NÃO comece executando.** Leia TODOS os desafios primeiro (5 min)
2. **Colete TODOS os recursos da solução** antes de tocar em qualquer coisa
3. **Inicie tarefas com tempo de espera primeiro** (RDS modifications, Instance Refresh)
4. **CloudShell está BLOQUEADO** neste lab. Tudo é feito pelo console
5. **O console está em português.** Campos de confirmação pedem texto em PT (ex: "excluir permanentemente", "confirmar")
6. **Os nomes nos recursos da solução podem estar traduzidos.** Verifique o nome real no console

## Fase 0: Reconhecimento (5 minutos)

### 0.1 Abra o Guia do Laboratório
Clique no link do guia dentro do Skill Builder. Leia o cenário para entender o contexto do ataque.

### 0.2 Colete os Recursos da Solução
Clique em "Recursos da Solução" e anote TUDO. Você vai precisar destes valores repetidamente:

| Recurso | Exemplo de valor |
|---------|-----------------|
| URL do aplicativo | http://LabSta-WebAL-xxx.us-east-1.elb.amazonaws.com |
| Banco de dados Athena | cloudtrail_logs (nome real, não o traduzido) |
| Grupo de Trabalho Athena | cloudtrail-analysis (nome real, não o traduzido) |
| ConfigBucketName | config-bucket-XXXXXX |
| Nome da função de configuração | lab-awsconfig-role-XXXXXX |
| Customer Data Bucket | customer-data-ACCOUNTID-us-east-1-XXXXXX |
| Security Group (DB) | sg-XXXXXXXXX |
| Forensic Bucket | incident-response-forensic-analysis-XXXXXX |
| Incident Response Trail | resposta-incidente-cloudtrail-XXXXXX |
| VPC ID | vpc-XXXXXXXXX |
| Security Group (server) | sg-XXXXXXXXX |
| WebServerASGName | (role para baixo nos recursos!) |
| WebServerLaunchTemplateId | (role para baixo nos recursos!) |
| ALBSecurityGroupId | (role para baixo nos recursos!) |

**IMPORTANTE:** Role para baixo nos recursos! Existem mais itens do que cabem na tela.

### 0.3 Leia todos os 6 desafios
Abra cada desafio e leia os critérios de sucesso. Isso evita retrabalho.

### 0.4 Defina a ordem de execução
A ordem recomendada (otimizada para tempo):

1. **Desafio UM** (RDS): inicie as modificações primeiro (demoram 5-10 min para aplicar)
2. **Desafio D** (S3/Athena/NACL): contenção de dados
3. **Desafio F** (EC2/AMI/Launch Template): identificação e remediação
4. **Desafio C** (IAM/SSM): erradicação de backdoors
5. **Desafio B** (Security Groups): segmentação de rede
6. **Desafio E** (CloudTrail/Config): auditoria e conformidade

## Desafio UM: Segurança do banco de dados (iniciar PRIMEIRO)

**Tempo estimado:** 3 min de configuração + 5-10 min de espera
**Por que primeiro:** As modificações do RDS demoram para aplicar. Inicie e vá para outros desafios.

### Passo 1: Modificar a instância RDS
1. Console RDS > Bancos de dados
2. Selecione a instância MySQL > **Modificar**
3. Altere:
   - **Acessibilidade pública:** Não acessível publicamente
   - **Retenção de backup:** 7 dias
   - **Proteção contra exclusão:** Habilitar
4. Clique "Continuar" > **Aplicar imediatamente** > Confirmar

**CRÍTICO:** Marque "Aplicar imediatamente" para não esperar a janela de manutenção.

### Passo 2: Evidências forenses (feito junto com Desafio D)
Os arquivos `database_dump.sql` e `database_dump.json` serão copiados para o bucket forense durante o Desafio D. Não precisa fazer separado.

## Desafio D: Conter exfiltração e bloquear atacante

**Tempo estimado:** 15-20 min
**Este é o desafio mais longo. Siga a ordem exata.**

### Passo 1: Identificar buckets do atacante no S3
1. Console S3 > Lista de buckets
2. Compare os **timestamps de criação**:
   - Buckets da infraestrutura: criados no mesmo horário (ex: 10:29)
   - Buckets do atacante: criados **minutos depois** (ex: 10:36)
3. Os buckets do atacante terão nomes inocentes como `data-backup-XXXXXX` e `db-archive-XXXXXX`

### Passo 2: Copiar evidências para o bucket forense
Para CADA bucket do atacante:
1. Entre no bucket > selecione todos os objetos
2. Ações > **Copiar**
3. Destino: `s3://incident-response-forensic-analysis-XXXXXX/`
4. Copiar

Arquivos esperados: `customer_data.csv`, `financial_transactions.csv`, `database_dump.sql`, `database_dump.json`

### Passo 3: Esvaziar e deletar buckets do atacante
Para CADA bucket do atacante:
1. Na lista de buckets, selecione o bucket
2. Clique **"Vazio"** > digite "excluir permanentemente" > confirme
3. Se der erro de permissão (DeleteObjectVersion), entre no bucket, selecione os objetos e delete individualmente
4. Depois: selecione o bucket > **"Excluir"** > digite o nome do bucket > confirme

### Passo 4: Block Public Access no bucket do cliente
1. Entre no bucket `customer-data-ACCOUNTID-us-east-1-XXXXXX`
2. Aba **Permissões**
3. Bloquear acesso público > **Editar** > marque **"Bloquear todo o acesso público"** > Salvar > digite "confirmar"
4. Política do bucket > **Excluir** > digite "excluir" (remove a policy pública com Principal: *)

### Passo 5: Block Public Access no nível da conta
1. S3 > Menu lateral > **Configurações de conta e organização**
2. Bloquear acesso público > **Editar** > marque **"Bloquear todo o acesso público"** > Salvar > digite "confirmar"

### Passo 6: Identificar IPs do atacante via Athena
1. Console Athena > Editor de consultas
2. **Troque o workgroup** para `cloudtrail-analysis` (NÃO use "primary", não tem permissão)
3. Se pedir local de resultados: use `s3://athena-result-bucket-XXXXXX/`
4. Banco de dados: `cloudtrail_logs`, tabela: `cloudtrail_events`
5. Execute a query:

```sql
SELECT * FROM cloudtrail_logs.cloudtrail_events LIMIT 1
```

6. Analise o resultado. Procure os campos `sourceipaddress` nos registros
7. Filtre IPs que NÃO são:
   - *.amazonaws.com (serviços AWS)
   - 10.x.x.x, 172.x.x.x, 192.168.x.x (IPs privados)
8. Os IPs restantes são do atacante (geralmente 3 Tor exit nodes)

### Passo 7: Bloquear IPs no Network ACL
1. Console VPC > ACLs da rede
2. Selecione a NACL associada à **LabVPC** (verifique o VPC ID)
3. Aba "Regras de entrada" > **Editar regras de entrada**
4. Adicione 3 regras DENY (uma para cada IP do atacante):

| Regra # | Tipo | Protocolo | Portas | Origem | Ação |
|---------|------|-----------|--------|--------|------|
| 50 | Todo o tráfego | Tudo | Tudo | IP_ATACANTE_1/32 | Deny |
| 51 | Todo o tráfego | Tudo | Tudo | IP_ATACANTE_2/32 | Deny |
| 52 | Todo o tráfego | Tudo | Tudo | IP_ATACANTE_3/32 | Deny |

5. **NÃO altere** a regra 100 (ALLOW). As regras DENY com números menores são avaliadas primeiro
6. Salvar

### Verificar
Clique "Verificar" no Desafio D e no Desafio UM (se o RDS já aplicou).

## Desafio F: Identificar e remediar recursos comprometidos

**Tempo estimado:** 10-15 min

### Passo 1: Identificar instâncias do atacante
1. Console EC2 > Instâncias
2. Identifique as instâncias suspeitas:
   - Security Group **"default"** (legítimas usam "WebServerSG")
   - **IP público** atribuído
   - **Sem Auto Scaling Group**
   - Nomes suspeitos (ex: WebServer-Backup-1, WebServer-Backup-2)

### Passo 2: Criar AMIs forenses
Para CADA instância do atacante:
1. Selecione a instância > Ações > Imagem e modelos > **Criar imagem**
2. Nome: `forensic-INSTANCE_ID`
3. Em Tags, adicione (marque "Etiquetar imagem e snapshots juntos"):
   - `incidenttype` = `crypto-mining`
   - `sourceinstance` = `INSTANCE_ID` (ex: i-0abc123def456)
4. Criar imagem

### Passo 3: Terminar instâncias do atacante
1. Selecione TODAS as instâncias do atacante
2. Estado da instância > **Encerrar (excluir) instância** > Confirmar

### Passo 4: Corrigir o Launch Template (IMDSv2)
1. EC2 > Modelos de execução (Launch Templates)
2. Selecione o template do WebServer
3. Ações > **Modificar modelo (criar nova versão)**
4. Role até "Detalhes avançados" > seção Metadados:
   - **Versão de metadados:** V2 only (token required)
   - **Limite de saltos de resposta de metadados:** 1
5. Criar versão
6. Volte ao template > Ações > **Definir versão padrão** > selecione a versão mais recente

### Passo 5: Atualizar o Auto Scaling Group
1. EC2 > Grupos Auto Scaling
2. Selecione o ASG do WebServer
3. Edite o Launch Template para usar **Latest** (versão mais recente)
4. Aba "Atualização da instância" > **Iniciar Instance Refresh**
5. Aguarde completar (3-5 min). Vá para outros desafios enquanto espera

### Verificar
Clique "Verificar". Se disser que instâncias não usam o template mais recente, aguarde o Instance Refresh completar.

## Desafio C: Erradicar backdoors e privilégio mínimo

**Tempo estimado:** 5-10 min

### Passo 1: Deletar IAM users backdoor
1. Console IAM > Usuários
2. Identifique users suspeitos (nomes como `system-backup-XXXXXX`, `app-admin-XXXXXX`)
3. Para cada user: clique no nome > **Excluir** > digite o nome > confirmar

### Passo 2: Deletar documentos do Systems Manager
1. Console Systems Manager > Documentos
2. Aba **"De minha propriedade"** (Owned by me)
3. Delete todos os documentos criados pelo atacante

### Passo 3: Corrigir a IAM Role da instância EC2
1. Console IAM > Funções (Roles)
2. Busque por "WebServer" > abra a role `WebServerRole-XXXXXX`
3. Na aba Permissões, identifique policies excessivas:
   - **REMOVER:** `AmazonS3FullAccess`, `IAMReadOnlyAccess`, `SecretsManagerReadWrite`
   - **MANTER:** `AmazonSSMManagedInstanceCore`, `CloudWatchAgentServerPolicy`, `WebServerRoleDefaultPolicy*`
4. Selecione as policies excessivas > **Remover**
5. Clique **"Adicionar permissões"** > Anexar políticas > busque `MinimalEC2InstancePolicy` > Anexar

### Verificar
Clique "Verificar" no Desafio C.

## Desafio B: Segmentação de rede

**Tempo estimado:** 5 min

### Conceito
A arquitetura correta é: Internet > ALB > Web Tier > Database Tier. Cada camada só aceita tráfego da camada anterior.

### Passo 1: Web tier Security Group
1. EC2 > Security Groups > selecione o WebServerSG (ID dos recursos)
2. Editar regras de entrada:
   - **Remover TODAS** as regras com 0.0.0.0/0 ou ranges amplos (10.0.0.0/8, all TCP)
   - **Adicionar:** TCP porta **5000**, origem = **ALB Security Group ID**
3. Deve ficar com APENAS UMA regra de entrada

### Passo 2: Database tier Security Group
1. EC2 > Security Groups > selecione o DB SG (ID dos recursos)
2. Editar regras de entrada:
   - **Remover TODAS** as regras com 0.0.0.0/0
   - **Adicionar:** TCP porta **3306**, origem = **Web tier Security Group ID**
3. Deve ficar com APENAS UMA regra de entrada

### Verificar
Clique "Verificar". Se falhar, verifique se não sobrou nenhuma regra com 0.0.0.0/0 ou ranges amplos.

## Desafio E: Controles de auditoria e conformidade

**Tempo estimado:** 10-15 min
**Este é o desafio mais complexo. Se o tempo estiver curto, faça na ordem de prioridade.**

### Passo 1: CloudTrail (prioridade alta, 1 min)
1. Console CloudTrail > Trilhas
2. Clique na trilha `resposta-incidente-cloudtrail-XXXXXX`
3. **Editar** > Habilitar **Validação de arquivo de log** > Salvar

### Passo 2: S3 Lifecycle (prioridade alta, 2 min)
1. Console S3 > bucket `incident-response-cloudtrail-XXXXXX`
2. Aba **Gerenciamento** > Criar regra de ciclo de vida
3. Nome: `log-retention`
4. Escopo: "Aplicar a todos os objetos" > marque "Reconheço..."
5. Marque "Transição de versões atuais" > Glacier Flexible Retrieval > **90** dias
   (ou "Expirar versões atuais" > 90 dias)
6. Criar regra

### Passo 3: AWS Config Recorder (prioridade média, 3 min)
1. Console AWS Config > Configurar
2. Método de gravação: **Todos os tipos de recursos com substituições personalizáveis**
3. Frequência: **Gravação contínua**
4. Se aparecer substituição de IAM global, clique **"Remover"** (para incluir tudo)
5. Função do IAM: **Escolher existente** > `lab-awsconfig-role-XXXXXX`
6. Bucket S3: **Escolher existente** > `config-bucket-XXXXXX`
7. Confirmar/Salvar

**Erros comuns:**
- "not authorized to perform s3:CreateBucket": selecione bucket EXISTENTE, não crie novo
- "not authorized to perform iam:CreateServiceLinkedRole": selecione role EXISTENTE, não crie nova

### Passo 4: AWS Config Regras (prioridade média, 5 min)
1. AWS Config > Regras > **Adicionar regra**
2. Adicione 6 regras gerenciadas AWS (uma por vez):

| Regra | O que verifica |
|-------|---------------|
| `s3-bucket-public-read-prohibited` | Buckets S3 sem leitura pública |
| `s3-bucket-public-write-prohibited` | Buckets S3 sem escrita pública |
| `rds-instance-public-access-check` | RDS sem acesso público |
| `restricted-ssh` | SGs sem SSH aberto (0.0.0.0/0) |
| `vpc-flow-logs-enabled` | VPC Flow Logs habilitados |
| `cloud-trail-cloud-watch-logs-enabled` | CloudTrail com CloudWatch Logs |

Para cada: Adicionar regra > busque o nome > Next > Next > Salvar (sem alterar parâmetros).

### Verificar
Clique "Verificar" no Desafio E.

## Checklist final (últimos 5 minutos)

Antes do tempo acabar, verifique TODOS os desafios:

- [ ] **UM** (RDS): Verificar (RDS pode ter terminado de aplicar)
- [ ] **D** (S3/NACL): Verificar
- [ ] **F** (EC2/AMI): Verificar (Instance Refresh pode ter completado)
- [ ] **C** (IAM/SSM): Verificar
- [ ] **B** (Security Groups): Verificar
- [ ] **E** (CloudTrail/Config): Verificar

Se algum falhar, leia a mensagem de erro com atenção. Geralmente indica exatamente o que falta.

## Dicas finais

1. **Não entre em pânico.** 90 minutos é suficiente se você seguir a ordem certa
2. **Leia as mensagens de erro.** Elas dizem exatamente o que está errado
3. **Se algo falhar 2 vezes, mude a abordagem.** Não insista no mesmo caminho
4. **Tarefas em paralelo:** enquanto RDS aplica mudanças ou Instance Refresh roda, trabalhe em outros desafios
5. **Os desafios são randomizados.** A ordem no painel pode ser diferente da ordem lógica
6. **Validade:** a microcredencial vale 1 ano. Se reprovar, espera de 25 dias para tentar novamente
7. **Credly:** após aprovação, você recebe um email da Credly com o selo digital para compartilhar no LinkedIn

Boa sorte! 🚀
