---
title: "OWASP Top 10: O que Todo SRE Precisa Saber sobre Segurança de Aplicações"
date: 2026-06-12T08:00:00-03:00
description: |
  Você opera a infraestrutura, mas quem protege a aplicação?

  O OWASP Top 10 é a lista das 10 vulnerabilidades mais críticas em aplicações web. Mesmo que você não escreva código, precisa conhecer:

  🔓 Broken Access Control (n°1 desde 2021)
  💉 Injection (SQL, NoSQL, OS command)
  🔑 Cryptographic Failures (dados sensíveis expostos)
  🪵 Security Logging Failures (sem log = sem evidência)

  Como SRE, você é a última linha de defesa. WAF, headers, TLS, rate limiting, logs de auditoria.

  Sua aplicação está protegida contra o Top 10?

  🔗 https://nerdseverino.com.br/blog/owasp-top-10-para-sres/

  #OWASP #Segurança #SRE #DevSecOps #WebSecurity #AppSec
cover:
  image: "/images/uploads/cover-owasp.png"
  alt: "Cover"
  relative: false
categories:
  - SRE
  - Segurança
tags:
  - serie-sre-na-pratica
  - owasp
  - segurança
  - devsecops
  - sre
  - web
keywords:
  - owasp top 10
  - segurança aplicações
  - vulnerabilidades web
  - devsecops
autoThumbnailImage: false
thumbnailImagePosition: top
---

O OWASP (Open Worldwide Application Security Project) é uma fundação sem fins lucrativos que mantém a lista mais referenciada de vulnerabilidades em aplicações web. O Top 10 é atualizado a cada poucos anos e serve como baseline de segurança para qualquer aplicação exposta à internet.

<!--more-->

## Por que SRE precisa conhecer OWASP

"Segurança é responsabilidade do desenvolvedor." Verdade, mas incompleta. Como SRE, você:

- Configura WAF, headers HTTP, TLS
- Opera load balancers e reverse proxies
- Gerencia logs de acesso e auditoria
- Responde a incidentes de segurança
- Define rate limiting e bloqueios

Você é a última linha de defesa entre o atacante e a aplicação.

## O Top 10 (2021, versão atual)

### A01: Broken Access Control

O número 1 da lista. Usuários acessando recursos que não deveriam.

**Exemplos:**
- Trocar `/api/users/123` para `/api/users/456` e ver dados de outro usuário
- Acessar painel admin sem autenticação
- Manipular tokens JWT para escalar privilégios

**O que o SRE pode fazer:**
- Configurar WAF rules para padrões de IDOR (Insecure Direct Object Reference)
- Monitorar logs de acesso para padrões anômalos (mesmo usuário acessando muitos IDs)
- Garantir que endpoints admin não estão expostos publicamente

### A02: Cryptographic Failures

Dados sensíveis expostos por criptografia fraca ou ausente.

**Exemplos:**
- Senhas armazenadas em MD5 ou SHA1
- Dados trafegando sem TLS
- Chaves de API em repositórios públicos
- Backups de banco sem criptografia

**O que o SRE pode fazer:**
- Forçar TLS 1.2+ em todos os endpoints (ALB, CloudFront, nginx)
- Habilitar encryption at rest (EBS, RDS, S3)
- Configurar headers: `Strict-Transport-Security`, `Content-Security-Policy`
- Monitorar certificados SSL (expiração)

```nginx
# Headers de segurança no nginx/ALB
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Content-Security-Policy "default-src 'self'" always;
```

### A03: Injection

Dados não confiáveis enviados como parte de um comando ou query.

**Tipos:**
- SQL Injection: `' OR 1=1 --`
- NoSQL Injection
- OS Command Injection: `; rm -rf /`
- LDAP Injection

**O que o SRE pode fazer:**
- WAF com regras para SQL injection (AWS WAF managed rules)
- Rate limiting em endpoints de login e busca
- Monitorar logs para padrões de injection (aspas, ponto-e-vírgula, UNION SELECT)

```bash
# Exemplo de regra WAF AWS (managed rule group)
# AWS-AWSManagedRulesSQLiRuleSet - bloqueia padrões de SQL injection
# AWS-AWSManagedRulesCommonRuleSet - regras gerais
```

### A04: Insecure Design

Falhas de design que nenhum código perfeito resolve.

**Exemplos:**
- Recuperação de senha que revela se o email existe
- Sem rate limiting em endpoints críticos
- Sem limite de tentativas de login

**O que o SRE pode fazer:**
- Implementar rate limiting (API Gateway, WAF, nginx)
- Configurar throttling por IP e por usuário
- Monitorar padrões de brute force

### A05: Security Misconfiguration

A mais comum em operação. Configurações padrão inseguras.

**Exemplos:**
- Portas desnecessárias abertas
- Páginas de erro expondo stack traces
- Buckets S3 públicos
- Credenciais padrão não alteradas
- Headers de servidor expondo versão

**O que o SRE pode fazer:**
- Audit de Security Groups (nada de 0.0.0.0/0 em portas que não sejam 80/443)
- S3 Block Public Access habilitado
- Remover headers de versão (`Server`, `X-Powered-By`)
- AWS Config rules para compliance contínua

```bash
# Verificar Security Groups abertos
aws ec2 describe-security-groups \
  --query 'SecurityGroups[?IpPermissions[?IpRanges[?CidrIp==`0.0.0.0/0`]]].[GroupId,GroupName]'

# Verificar buckets públicos
aws s3api list-buckets --query 'Buckets[].Name' --output text | \
  xargs -I{} aws s3api get-public-access-block --bucket {} 2>&1
```

### A06: Vulnerable and Outdated Components

Bibliotecas, frameworks e sistemas desatualizados com CVEs conhecidas.

**O que o SRE pode fazer:**
- Manter SO e pacotes atualizados (patch management)
- Monitorar CVEs dos componentes em uso
- Automatizar updates de segurança
- Usar imagens Docker com base mínima (alpine, distroless)

### A07: Identification and Authentication Failures

Falhas em autenticação e gerenciamento de sessão.

**Exemplos:**
- Sem MFA
- Sessões que não expiram
- Senhas fracas permitidas
- Tokens previsíveis

**O que o SRE pode fazer:**
- Forçar MFA no console AWS e aplicações críticas
- Configurar session timeout
- Monitorar tentativas de login falhas (fail2ban, CloudWatch)
- Rate limiting em endpoints de autenticação

### A08: Software and Data Integrity Failures

Código ou dados modificados sem verificação de integridade.

**Exemplos:**
- CI/CD pipeline sem verificação de assinatura
- Dependências de terceiros sem lock file
- Updates automáticos sem validação

**O que o SRE pode fazer:**
- Assinar artefatos de deploy
- Verificar checksums de downloads
- Usar lock files (package-lock.json, Pipfile.lock)
- Imagens Docker com digest específico (não apenas :latest)

### A09: Security Logging and Monitoring Failures

Sem logs adequados, você não detecta ataques e não tem evidências para investigar.

**O que o SRE pode fazer:**
- CloudTrail habilitado em todas as contas e regiões
- VPC Flow Logs habilitados
- Logs de acesso do ALB/CloudFront
- GuardDuty ativado
- Retenção de logs adequada (mínimo 90 dias, compliance pode exigir mais)
- Alertas para eventos de segurança (login root, mudança de Security Group)

```bash
# Verificar CloudTrail
aws cloudtrail describe-trails --query 'trailList[].{Name:Name,IsMultiRegion:IsMultiRegionTrail,IsLogging:IsLogging}'

# Verificar GuardDuty
aws guardduty list-detectors
```

### A10: Server-Side Request Forgery (SSRF)

Aplicação faz requisições para URLs controladas pelo atacante.

**Exemplos:**
- Acessar metadata da EC2: `http://169.254.169.254/latest/meta-data/`
- Acessar serviços internos via aplicação exposta

**O que o SRE pode fazer:**
- IMDSv2 obrigatório em todas as EC2 (bloqueia SSRF ao metadata)
- Firewall rules bloqueando acesso ao 169.254.169.254 de containers
- WAF rules para detectar padrões de SSRF

```bash
# Forçar IMDSv2 em instância existente
aws ec2 modify-instance-metadata-options \
  --instance-id i-xxx \
  --http-tokens required \
  --http-endpoint enabled
```

## Checklist de segurança para SREs

| Área | Ação |
|------|------|
| TLS | 1.2+ em todos os endpoints |
| Headers | HSTS, CSP, X-Frame-Options, X-Content-Type-Options |
| WAF | Managed rules para SQLi, XSS, SSRF |
| Rate limiting | Em login, API, busca |
| Logs | CloudTrail, VPC Flow Logs, ALB access logs |
| Detecção | GuardDuty, alertas de segurança |
| Patches | SO e pacotes atualizados |
| S3 | Block Public Access habilitado |
| IAM | MFA, menor privilégio, sem access keys |
| EC2 | IMDSv2, Security Groups mínimos |
| Encryption | At rest e in transit |

## Recursos

- [OWASP Top 10 (2021)](https://owasp.org/www-project-top-ten/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [AWS WAF Managed Rules](https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups.html)
- [AWS Security Best Practices](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/)

---

*Segurança não é responsabilidade de um time só. Como SRE, você controla a infraestrutura que protege (ou expõe) a aplicação. Conhecer o OWASP Top 10 te dá vocabulário para conversar com devs, argumentar por mudanças e implementar as defesas que estão ao seu alcance.*
