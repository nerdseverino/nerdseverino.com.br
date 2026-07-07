---
title: "Patterns de Resiliência: Circuit Breaker, Bulkheads e Timeouts"
date: 2026-07-15T08:00:00-03:00
description: |
  Um serviço lento é pior que um serviço fora. Ele derruba tudo ao redor.

  Patterns que previnem cascading failures:
  ⚡ Circuit Breaker: para de chamar serviço que está falhando
  ⚡ Bulkheads: isola falhas para não contaminar tudo
  ⚡ Timeouts: nunca espere para sempre
  ⚡ Retry com backoff: tente de novo, mas com inteligência

  Esses patterns salvam mais que qualquer dashboard.

  Sua aplicação tem circuit breaker ou espera até dar timeout?

  🔗 https://nerdseverino.com.br/blog/patterns-de-resiliencia/

  #SRE #Resiliência #CircuitBreaker #DevOps #Arquitetura
categories:
  - SRE
tags:
  - sre
  - resiliência
  - arquitetura
  - patterns
  - serie-sre-na-pratica
keywords:
  - circuit breaker
  - bulkheads
  - timeouts
  - retry backoff
  - cascading failures
autoThumbnailImage: false
thumbnailImagePosition: top
---

O livro "Release It!" de Michael Nygard documenta um padrão que todo SRE já viu: um serviço lento que derruba toda a cadeia. Não é o serviço que caiu que causa o maior estrago. É o que ficou lento e travou todos que dependiam dele.

<!--more-->

## Cascading Failures

Cenário real: Serviço A chama Serviço B. B fica lento (banco sobrecarregado). A acumula threads esperando B. A para de responder. C, que depende de A, também trava. Em minutos, tudo está fora.

A causa raiz era B. Mas o impacto foi total porque não havia isolamento.

## Circuit Breaker

Inspirado em disjuntores elétricos. Quando um serviço falha repetidamente, o circuit breaker "abre" e para de chamá-lo:

| Estado | Comportamento |
|--------|--------------|
| **Closed** | Normal, requisições passam |
| **Open** | Falhas demais, requisições bloqueadas (retorna erro imediato) |
| **Half-Open** | Testa periodicamente se o serviço voltou |

Benefício: falha rápida ao invés de esperar timeout. Libera threads e recursos.

```
Sem circuit breaker:
  Request → espera 30s → timeout → retry → espera 30s → timeout
  (1 minuto perdido, thread presa)

Com circuit breaker:
  Request → circuit open → erro imediato (5ms)
  (thread liberada, usuário recebe erro rápido)
```

## Bulkheads

Inspirado em compartimentos de navios. Se um compartimento alaga, os outros continuam intactos.

Na prática: pools de conexão separados por serviço dependente.

```
Sem bulkhead:
  Pool único de 100 threads para tudo
  Serviço B lento → consome 100 threads → ninguém mais é atendido

Com bulkhead:
  Pool A: 30 threads (serviço A)
  Pool B: 30 threads (serviço B)
  Pool C: 40 threads (serviço C)
  Serviço B lento → consome 30 threads → A e C continuam funcionando
```

## Timeouts

A regra mais simples e mais ignorada: nunca espere para sempre.

| Tipo de chamada | Timeout sugerido |
|----------------|-----------------|
| API interna | 1-5 segundos |
| Banco de dados | 5-10 segundos |
| API externa | 5-15 segundos |
| DNS | 2 segundos |
| Health check | 3 segundos |

Timeout sem retry = falha. Timeout com retry inteligente = resiliência.

## Retry com Backoff Exponencial

```
Tentativa 1: espera 100ms
Tentativa 2: espera 200ms
Tentativa 3: espera 400ms
Tentativa 4: espera 800ms
(máximo 3-5 tentativas)
```

Adicione **jitter** (variação aleatória) para evitar thundering herd: todos os clientes retentando ao mesmo tempo.

## Como o SRE aplica isso

Mesmo sem escrever código da aplicação, o SRE pode:

1. **Configurar timeouts** no ALB, nginx, API Gateway
2. **Monitorar** latência p99 e taxa de erro por dependência
3. **Alertar** quando latência sobe (indicador de cascading failure iminente)
4. **Documentar** dependências entre serviços (quem chama quem)
5. **Testar** resiliência (desligar um serviço e ver o que acontece)

```nginx
# Timeout no nginx
proxy_connect_timeout 5s;
proxy_read_timeout 10s;
proxy_send_timeout 5s;
```

```yaml
# Timeout no ALB (target group)
# Deregistration delay: 30s
# Health check timeout: 5s
# Health check interval: 10s
# Unhealthy threshold: 3
```

---

*Resiliência não é evitar falhas. É garantir que uma falha não derrube tudo. Circuit breaker, bulkheads e timeouts são os três patterns mais importantes que um SRE pode defender na arquitetura.*
