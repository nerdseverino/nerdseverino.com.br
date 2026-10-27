---
title: "Todo sistema vai cair. A diferença é se ele afunda junto ou não"
cover:
  image: /images/uploads/padroes-de-resiliencia-como-sistemas-sobrevivem.jpeg
  alt: "Todo sistema vai cair. A diferença é se ele afunda junto ou não"
date: 2026-10-27T01:25:00-03:00
description: |
  Todo sistema vai falhar. A diferença entre um bom e um ruim é como ele falha.

  Os padrões que fazem sistemas sobreviverem:

  🔁 Idempotência: repetir a operação sem duplicar efeito
  ⏱️ Timeout + retry com backoff e jitter
  🚧 Bulkhead: isolar falhas para não afundar o navio todo
  ⚡ Circuit breaker: parar de bater numa porta fechada
  📦 Cache como camada de resiliência

  Não é sobre evitar falhas. É sobre falhar pequeno e se recuperar rápido.

  Conta aí: qual foi a vez que faltou um desses padrões e o sistema afundou junto?

  #SystemDesign #SRE #DevOps #Arquitetura
categories:
  - SRE
  - Arquitetura
tags:
  - system-design
  - sre
  - resiliência
  - arquitetura
  - padrões
keywords:
  - padrões de resiliência
  - idempotência
  - circuit breaker
  - bulkhead pattern
  - timeout retry backoff
autoThumbnailImage: false
thumbnailImagePosition: top
---

Existe uma frase que todo SRE acaba internalizando: não é questão de SE o sistema vai falhar, é QUANDO. A engenharia de confiabilidade não tenta eliminar falhas (impossível), ela projeta sistemas que falham de forma controlada e se recuperam rápido. Vamos aos padrões que tornam isso possível.

<!--more-->

## Idempotência: o alicerce

Idempotência é, provavelmente, o padrão mais importante para sistemas distribuídos. A ideia: executar a mesma operação várias vezes produz sempre o mesmo resultado, sem efeitos colaterais.

O exemplo clássico é uma API de pagamento. O cliente envia uma cobrança, a rede cai antes da resposta chegar, o cliente reenvia. Sem idempotência, você cobra duas vezes. Com idempotência, a segunda requisição é reconhecida e ignorada.

Como implementar: o cliente envia uma **chave de idempotência** única (via header ou payload). O servidor verifica se já processou aquela chave antes de executar.

```text
POST /cobranca
Idempotency-Key: 7f3a9b2c-1234-5678

Primeira vez: processa, armazena a chave, cobra
Segunda vez (mesma chave): retorna o resultado anterior, não cobra de novo
```

Por que é o alicerce? Porque idempotência habilita todos os outros padrões. Sem ela, você não pode fazer retry com segurança.

## Timeouts: não espere para sempre

Um timeout define o limite de tempo para uma operação. Parece óbvio, mas a ausência de timeout é uma das causas mais comuns de cascata de falhas.

Imagine o serviço A chamando o serviço B. B travou. Sem timeout, A fica esperando indefinidamente, segurando conexões e threads. Logo A também trava. Depois C, que chama A. A falha se propaga.

```text
# Sem timeout: A espera para sempre, trava junto com B
resposta = chamar_servico_b()

# Com timeout: A desiste após 3s e lida com o erro
resposta = chamar_servico_b(timeout=3s)
```

Regra prática: todo cliente HTTP, toda query de banco, toda chamada externa precisa de timeout. Sem exceção.

## Retry com backoff e jitter

Timeout sozinho não basta. Falhas transitórias (rede instável, host reiniciando) merecem uma segunda chance. Mas retry ingênuo piora as coisas.

Se 1000 clientes falham ao mesmo tempo e todos tentam de novo no mesmo instante, você cria um "thundering herd" que derruba o serviço que estava se recuperando.

A solução é **backoff exponencial + jitter**:

```text
Tentativa 1: espera 1s  + aleatório(0-1s)
Tentativa 2: espera 2s  + aleatório(0-1s)
Tentativa 3: espera 4s  + aleatório(0-1s)
Tentativa 4: espera 8s  + aleatório(0-1s)
```

O backoff exponencial dá tempo ao serviço se recuperar. O jitter (aleatoriedade) espalha as tentativas para não baterem todas juntas.

## Circuit Breaker: pare de bater na porta fechada

Se um serviço está fora, continuar tentando é desperdício e piora a situação. O circuit breaker funciona como o disjuntor da sua casa.

Três estados:

| Estado | Comportamento |
|--------|---------------|
| Closed | Tudo normal, requisições passam |
| Open | Serviço falhou demais, requisições são rejeitadas na hora (fail fast) |
| Half-Open | Após um tempo, deixa passar algumas para testar se recuperou |

Quando o circuito "abre", em vez de esperar o timeout de cada requisição, você falha instantaneamente e retorna um fallback (cache, resposta degradada, erro amigável). Isso protege tanto o chamador quanto o serviço em recuperação.

## Bulkhead: compartimentos estanques

O nome vem dos navios: o casco é dividido em compartimentos isolados, então um furo não afunda o navio inteiro. Na arquitetura, o bulkhead isola recursos para que a falha de um componente não consuma tudo.

Exemplo prático: se seu serviço tem um pool de 100 conexões e uma dependência lenta consome todas, o serviço inteiro para. Com bulkhead, você separa pools: 30 conexões para a dependência A, 30 para a B, 40 para o resto. A lentidão de A não afeta B nem o restante.

Isso se conecta com sharding e arquitetura celular: dividir para isolar o blast radius.

## Cache como resiliência

A gente pensa em cache como otimização de performance, mas ele também é mecanismo de resiliência. Quando a fonte de dados cai, um cache bem configurado mantém o sistema funcionando.

Uma CDN pode sustentar o front-end durante horas de indisponibilidade da origem. Um cache de dados com fallback permite servir respostas (mesmo que levemente desatualizadas) quando o banco está fora.

A chave é projetar políticas de expiração e fallback conscientes:

| Estratégia | Resiliência |
|-----------|-------------|
| Cache-Aside | Serve do cache em miss só se a origem responder |
| TTL longo + fallback | Serve dado "velho" se a origem cair |
| CDN | Sustenta front-end durante quedas de origem |

## O princípio que amarra tudo: blast radius

Todos esses padrões servem a um objetivo: reduzir o blast radius. A pergunta certa não é "como evitar que caia?", é "quando cair, quanto do sistema vai junto?".

Empresas como a Netflix projetam para falhar pequeno: células independentes, dependências isoladas, impacto limitado automaticamente. Uma falha afeta 1% dos usuários, não 100%.

## Checklist de resiliência

Antes de colocar um serviço em produção:

- [ ] Toda chamada externa tem timeout
- [ ] Operações críticas são idempotentes
- [ ] Retry usa backoff exponencial + jitter
- [ ] Dependências instáveis têm circuit breaker
- [ ] Pools de recursos são isolados (bulkhead)
- [ ] Cache tem política de fallback para quedas de origem
- [ ] Healthcheck reflete o estado real (valida dependências)

---

*Resiliência não é um recurso que você adiciona depois. É uma decisão de arquitetura que permeia cada chamada, cada timeout, cada pool de conexão. O sistema vai falhar. A pergunta é se ele vai afundar junto ou isolar o dano e seguir operando. Esses padrões são a diferença entre as duas coisas.*
