---
title: "Knowledge Bases no Kiro CLI: dando contexto especializado"
date: 2026-05-11T11:30:00-03:00
cover:
  image: /images/uploads/knowledge-bases-no-kiro.jpeg
  alt: "Knowledge Bases no Kiro CLI"
description: |
  O Kiro sabe muito sobre tecnologia em geral. Mas ele não sabe nada sobre o SEU ambiente.

  Knowledge bases resolvem isso: você indexa seus docs, manuais e configs, e o Kiro busca neles antes de responder.

  📚 Documentação do Zabbix → respostas precisas sobre sua versão
  📚 Manual do GLPI → comandos corretos da sua API
  📚 Configs SSH → sabe quais servidores você tem
  📚 Runbooks → segue seus procedimentos, não genéricos

  É RAG local, sem cloud, sem custo extra.

  Quais documentos você indexaria primeiro?

  🔗 https://nerdseverino.com.br/blog/knowledge-bases-no-kiro/

  #KiroCLI #AI #KnowledgeBase #RAG #Produtividade #SRE
categories:
  - DevOps
  - Ferramentas
tags:
  - kiro
  - knowledge-base
  - ia
  - rag
keywords:
  - kiro knowledge base
  - rag local
  - contexto ia
autoThumbnailImage: false
thumbnailImagePosition: top
---

O Kiro CLI tem conhecimento amplo sobre tecnologia, mas não sabe nada sobre o seu ambiente específico: seus servidores, suas versões, seus procedimentos. Knowledge bases resolvem isso indexando seus documentos localmente para busca semântica.

<!--more-->

## O que são Knowledge Bases no Kiro

Knowledge bases são coleções de documentos indexados localmente que o Kiro consulta via busca semântica antes de responder. É como um RAG (Retrieval Augmented Generation) pessoal, sem cloud, sem custo extra.

Quando você pergunta "como reiniciar o proxy Zabbix?", o Kiro busca na sua knowledge base de runbooks e retorna o procedimento específico do seu ambiente, não uma resposta genérica.

## Criando uma Knowledge Base

```bash
# Indexar um diretório inteiro
# O Kiro detecta automaticamente: Markdown, PDF, código, texto

# Via comando no chat:
"indexa /home/usuario/docs/zabbix como 'Zabbix Docs'"
```

O Kiro processa os arquivos, divide em chunks, gera embeddings e armazena localmente. A busca é por similaridade semântica, não apenas por palavras-chave.

## O que indexar

### Documentação de ferramentas

- Manual do Zabbix (sua versão específica)
- Documentação do GLPI
- Guias do Steampipe
- Docs de ferramentas internas

### Configurações e referências

- Contexto SSH (servidores, IPs, chaves)
- Inventário de contas AWS
- Diagramas de rede (em texto/markdown)
- Variáveis de ambiente documentadas

### Procedimentos operacionais

- Runbooks de suporte (N1, N2, N3)
- Playbooks de incidentes
- Checklists de deploy
- Procedimentos de backup

### Material de estudo

- PDFs de certificações
- Artigos técnicos salvos
- Notas de treinamentos

## Gerenciando Knowledge Bases

```bash
# Listar knowledge bases
# No chat: "lista minhas knowledge bases"

# Buscar em uma KB específica
# No chat: "busca 'como configurar proxy' na KB do Zabbix"

# Buscar em todas
# No chat: "busca 'timeout connection' em todas as KBs"

# Atualizar (quando os docs mudam)
# No chat: "atualiza a KB do Zabbix"

# Remover
# No chat: "remove a KB de testes"
```

## Dicas de organização

**Separe por domínio**: Uma KB para Zabbix, outra para AWS, outra para runbooks. Busca mais precisa.

**Mantenha atualizado**: Docs desatualizados geram respostas erradas. Atualize quando mudar de versão.

**Prefira Markdown**: O Kiro processa melhor texto estruturado. PDFs funcionam mas Markdown é mais preciso.

**Tamanho importa**: KBs muito grandes diluem a relevância. Melhor 50 docs focados que 500 genéricos.

## Exemplo prático

Sem KB:
```text
Pergunta: "como verificar se o proxy Zabbix está online?"
Resposta: procedimento genérico do Zabbix docs oficial
```

Com KB indexada com seus runbooks:
```text
Pergunta: "como verificar se o proxy Zabbix está online?"
Resposta: "Conforme o runbook, verificar EC2 running + SSM online,
          depois cd /opt/zabbix && docker-compose ps.
          Se offline, docker-compose pull && docker-compose up -d.
          Verificar TCP na porta 10051."
```

A diferença é contexto. O Kiro responde com o SEU procedimento, não com um genérico.

---

*Knowledge bases transformam o Kiro de um assistente genérico em um especialista no seu ambiente. O investimento é indexar seus docs uma vez. O retorno é respostas precisas e contextualizadas em toda sessão.*
