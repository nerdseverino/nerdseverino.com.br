---
title: "Kiro CLI: Dicas e Truques para Aumentar sua Produtividade"
date: 2026-02-02T04:37:00.000Z
categories:
  - DevOps
  - Ferramentas
tags:
  - kiro
  - cli
  - ia
  - produtividade
  - aws
keywords:
  - kiro
  - cli
  - inteligencia artificial
  - aws
  - automacao
autoThumbnailImage: false
thumbnailImagePosition: top
---

O **Kiro CLI** é uma ferramenta de IA da AWS que funciona como um assistente inteligente no terminal. Depois de alguns meses usando diariamente, compilei as melhores dicas para aproveitar ao máximo essa ferramenta.

## O Que é o Kiro CLI?

Kiro é um assistente de IA que roda no terminal e pode:
- Executar comandos no sistema
- Ler e modificar arquivos
- Fazer chamadas AWS CLI
- Criar e debugar código
- Automatizar tarefas repetitivas
- Acessar documentação AWS

## Instalação

### macOS

Instalação nativa via curl:

```bash
curl -fsSL https://cli.kiro.dev/install | bash
```

Após a instalação, o Kiro abrirá seu navegador para autenticação.

### Linux

#### Opção 1: AppImage (Recomendado)

```bash
# Download
wget https://desktop-release.q.us-east-1.amazonaws.com/latest/kiro-cli.appimage

# Tornar executável
chmod +x kiro-cli.appimage

# Executar
./kiro-cli.appimage
```

#### Opção 2: Ubuntu (.deb)

```bash
# Download
wget https://desktop-release.q.us-east-1.amazonaws.com/latest/kiro-cli.deb

# Instalar
sudo dpkg -i kiro-cli.deb
sudo apt-get install -f

# Executar
kiro-cli
```

#### Opção 3: Arquivo ZIP

Verifique sua versão do glibc:

```bash
ldd --version
```

**Para glibc 2.34+ (padrão):**

```bash
# x86_64
curl --proto '=https' --tlsv1.2 -sSf \
  'https://desktop-release.q.us-east-1.amazonaws.com/latest/kirocli-x86_64-linux.zip' \
  -o 'kirocli.zip'

# ARM (aarch64)
curl --proto '=https' --tlsv1.2 -sSf \
  'https://desktop-release.q.us-east-1.amazonaws.com/latest/kirocli-aarch64-linux.zip' \
  -o 'kirocli.zip'
```

**Para glibc < 2.34 (versão musl):**

```bash
# x86_64
curl --proto '=https' --tlsv1.2 -sSf \
  'https://desktop-release.q.us-east-1.amazonaws.com/latest/kirocli-x86_64-linux-musl.zip' \
  -o 'kirocli.zip'

# ARM (aarch64)
curl --proto '=https' --tlsv1.2 -sSf \
  'https://desktop-release.q.us-east-1.amazonaws.com/latest/kirocli-aarch64-linux-musl.zip' \
  -o 'kirocli.zip'
```

**Instalar:**

```bash
unzip kirocli.zip
./kirocli/install.sh
```

Por padrão, os arquivos são instalados em `~/.local/bin`.

### Configuração de Proxy (Empresas)

Se você usa proxy corporativo:

```bash
# HTTP proxy
export HTTP_PROXY=http://proxy.empresa.com:8080
export HTTPS_PROXY=http://proxy.empresa.com:8080

# Bypass para domínios específicos
export NO_PROXY=localhost,127.0.0.1,.empresa.com

# Com autenticação
export HTTP_PROXY=http://usuario:senha@proxy.empresa.com:8080
```

### Verificar Instalação

```bash
# Diagnosticar problemas
kiro-cli doctor

# Saída esperada:
# ✔ Everything looks good!
```

### Desinstalar

**macOS:**
```bash
kiro-cli uninstall
```

**Ubuntu:**
```bash
sudo apt-get remove kiro-cli
sudo apt-get purge kiro-cli  # Remove configurações
```

**Documentação oficial**: [kiro.dev/docs/cli/installation](https://kiro.dev/docs/cli/installation/)

## Dicas Essenciais

### 1. Use Contexto de Arquivos

O Kiro pode ler arquivos para entender o contexto:

```bash
# Iniciar chat
kiro-cli chat

# No chat
> leia os arquivos da pasta src/ para contexto
> agora corrija os erros de lint em todos os arquivos
```

### 2. Comandos Slash Úteis

```bash
/save nome_sessao     # Salvar conversa
/load nome_sessao     # Carregar conversa salva
/context              # Ver contexto atual
/model                # Ver/trocar modelo de IA
/quit                 # Sair
```

### 3. Delegação de Tarefas

Para tarefas complexas, use subagentes:

```bash
> use subagent para criar testes unitários para todos os arquivos Python
> delegue a criação de documentação para um agente especializado
```

### 4. Integração com AWS

```bash
> liste todas as instâncias EC2 na região us-east-1
> mostre os logs do CloudWatch do último erro
> crie um bucket S3 com versionamento habilitado
```

### 5. Automação de Scripts

```bash
> crie um script bash que faça backup do banco de dados diariamente
> adicione tratamento de erros e notificação por email
> torne o script executável e adicione ao cron
```

## Casos de Uso Práticos

### Troubleshooting Rápido

```bash
> o serviço nginx não está iniciando, diagnostique o problema
> verifique os logs e sugira correções
```

O Kiro vai:
1. Verificar status do serviço
2. Ler logs de erro
3. Verificar configuração
4. Sugerir correções

### Refatoração de Código

```bash
> refatore este arquivo Python para usar type hints
> adicione docstrings em todas as funções
> aplique PEP 8
```

### Criação de Infraestrutura

```bash
> crie um Terraform para provisionar:
> - VPC com 2 subnets públicas e 2 privadas
> - ALB com target group
> - Auto Scaling Group com instâncias t3.micro
```

### Análise de Logs

```bash
> analise os logs do nginx e identifique os 10 IPs com mais requisições
> mostre os endpoints mais acessados
> identifique possíveis ataques
```

## Boas Práticas

### 1. Seja Específico

❌ **Ruim**: "arrume o código"
✅ **Bom**: "refatore a função `process_data()` para usar list comprehension e adicione type hints"

### 2. Use Contexto Incremental

```bash
> leia o arquivo config.yaml
> agora leia o docker-compose.yml
> baseado nesses arquivos, crie um Kubernetes deployment
```

### 3. Peça Explicações

```bash
> explique o que este comando faz: awk '{sum+=$1} END {print sum}'
> qual a diferença entre docker run e docker exec?
```

### 4. Valide Antes de Executar

```bash
> mostre o comando que você vai executar antes de rodar
> faça um dry-run primeiro
```

### 5. Salve Sessões Importantes

```bash
/save deploy_producao_20260202
/save troubleshooting_nginx
/save refactor_api
```

## Truques Avançados

### 1. Análise de Código Complexo

```bash
> analise este repositório e identifique:
> - código duplicado
> - funções muito longas
> - falta de testes
> - vulnerabilidades de segurança
```

### 2. Geração de Documentação

```bash
> gere um README.md completo para este projeto
> inclua: instalação, uso, exemplos, contribuição
> adicione badges do GitHub
```

### 3. Migração de Código

```bash
> converta este script bash para Python
> mantenha a mesma funcionalidade
> adicione tratamento de erros melhor
```

### 4. Otimização de Performance

```bash
> analise este código Python e sugira otimizações
> identifique gargalos de performance
> mostre benchmarks antes e depois
```

### 5. Criação de Testes

```bash
> crie testes unitários para todas as funções
> use pytest e mocking onde necessário
> garanta 80%+ de cobertura
```

## Integração com Workflow

### Git Workflow

```bash
> crie um branch feature/nova-funcionalidade
> implemente a funcionalidade X
> crie testes
> faça commit com mensagem descritiva
> crie pull request
```

### CI/CD

```bash
> crie um GitHub Actions workflow que:
> - rode testes em cada push
> - faça build da imagem Docker
> - faça deploy no ECS se for branch main
```

### Documentação

```bash
> documente todas as funções deste arquivo
> crie um guia de uso em markdown
> adicione exemplos práticos
```

## Limitações e Cuidados

### ⚠️ Sempre Revise

- Kiro pode cometer erros
- Revise comandos destrutivos
- Teste em ambiente de dev primeiro

### ⚠️ Dados Sensíveis

- Não compartilhe senhas ou tokens
- Use variáveis de ambiente
- Kiro substitui PII automaticamente

### ⚠️ Contexto Limitado

- Kiro tem limite de tokens
- Para arquivos grandes, seja seletivo
- Use `/context` para ver uso

## Comandos de Referência Rápida

```bash
# Iniciar chat
kiro-cli chat

# Comandos no chat
/save sessao          # Salvar
/load sessao          # Carregar
/context              # Ver contexto
/model                # Trocar modelo
/quit                 # Sair

# Exemplos de uso
> leia arquivo.py
> crie testes para este código
> explique este erro
> otimize esta query SQL
> crie um Dockerfile
```

## Recursos Adicionais

### Documentação Oficial
- [Kiro CLI Docs](https://docs.aws.amazon.com/kiro/)
- [GitHub Repository](https://github.com/aws/kiro-cli)

### Comunidade
- [Discord da AWS](https://discord.gg/aws)
- [Stack Overflow - tag: kiro-cli](https://stackoverflow.com/questions/tagged/kiro-cli)

### Tutoriais
- [AWS Workshop - Kiro CLI](https://workshop.aws/)
- [YouTube - AWS Tutorials](https://youtube.com/@aws)

## Conclusão

O Kiro CLI é uma ferramenta poderosa que pode aumentar significativamente sua produtividade. A chave é:

1. **Ser específico** nas solicitações
2. **Usar contexto** adequadamente
3. **Revisar** sempre o output
4. **Salvar** sessões importantes
5. **Experimentar** diferentes abordagens

Com o tempo, você desenvolverá seu próprio workflow e descobrirá novos casos de uso.

## Sua Experiência

Você usa Kiro CLI? Tem alguma dica que não mencionei? Compartilhe nos comentários ou entre em contato:

- **LinkedIn**: [linkedin.com/in/fabriciomachado](https://www.linkedin.com/in/fabriciomachado)
- **GitHub**: [github.com/nerdseverino](https://github.com/nerdseverino)

---

**Tags**: #KiroCLI #AWS #IA #DevOps #Produtividade #Automação
