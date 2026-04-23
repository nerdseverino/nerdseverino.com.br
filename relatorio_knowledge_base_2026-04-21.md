# Relatório: Inventário da Base de Conhecimento

> Data: 2026-04-21 | Total: 23 Knowledge Bases | ~3.385 itens indexados

## Visão Geral

Esta base de conhecimento cobre as principais áreas de atuação de um SRE/DevOps, desde monitoramento e infraestrutura até certificações cloud e desenvolvimento de carreira. O material inclui documentação oficial, livros técnicos, artigos, simulados de certificação e templates operacionais.

## 1. Monitoramento (Zabbix)

A maior concentração de conteúdo da base, com 3.305 itens distribuídos em três KBs.

| Base | Itens | Conteúdo |
|:--|--:|:--|
| Zabbix 7.4 Documentation | 1.457 | Documentação oficial completa da versão mais recente |
| Zabbix Training PDFs | 1.661 | Material de treinamento em PDF (curso completo) |
| Zabbix 6.4 Documentation | 187 | Documentação oficial da versão 6.4 |

Tópicos cobertos: instalação, configuração de hosts/templates/triggers, discovery, alertas, dashboards, API, alta disponibilidade, proxies, autenticação, macros, mapas de rede, relatórios, manutenção, monitoramento web, SNMP, JMX, IPMI, agentes ativos/passivos.

## 2. AWS

Três bases cobrindo certificação, otimização de custos e arquiteturas.

| Base | Itens | Conteúdo |
|:--|--:|:--|
| AWS Cert SAA-C03 | 11 | Simulados (dumps) e resumos comentados para a certificação Solutions Architect Associate |
| AWS Artigos | 7 | Artigos técnicos: FinOps, extração de dados via SES/S3/Lambda, análise de custos AWS |
| FinOps Guia Completo | 1 | Guia consolidado de práticas FinOps |

Tópicos cobertos na certificação: EC2, S3, RDS, VPC, IAM, Lambda, DynamoDB, CloudFront, Route 53, ECS/EKS, Auto Scaling, Load Balancers, Direct Connect, Kinesis, SQS/SNS, Secrets Manager, KMS, Shield/WAF, Athena, QuickSight, Cost Explorer.

Tópicos cobertos em FinOps: tagging, scheduling non-prod, seleção de instâncias, Spot vs On-Demand, rightsizing, Kubernetes cost engineering (Kubecost, Karpenter, VPA), GPU FinOps, storage lifecycle, shift-left com Infracost, portfólio de commitments (RIs/Savings Plans), unit economics, cultura e organização FinOps.

## 3. Containers e Orquestração (Docker/Kubernetes)

| Base | Itens | Conteúdo |
|:--|--:|:--|
| Docker Knowledge Base | 8 | Livros e estrutura de curso |

Fontes: "Docker para Desenvolvedores" (Rafael Gomes), "Descomplicando o Docker 2ª Ed." (Jeferson Fernando), "Descomplicando Kubernetes: Secrets e ConfigMaps".

Tópicos cobertos: fundamentos de containers, namespaces, cgroups, storage drivers (AUFS, OverlayFS, BTRFS), Dockerfile, Docker Compose, Docker Swarm, redes, volumes, multi-stage builds, segurança, monitoramento (Prometheus, Grafana, cAdvisor), metodologia 12-Factor, Kubernetes Secrets, ConfigMaps, TLS/HTTPS em pods. Inclui estrutura completa de curso progressivo em 9 módulos.

## 4. SRE e Confiabilidade

| Base | Itens | Conteúdo |
|:--|--:|:--|
| SRE Knowledge Base | 20 | Livro e artigos técnicos |

Fontes: "Release It! Design and Deploy Production-Ready Software" (Michael Nygard), série "SRE na Prática" (Emmanuel Martins).

Tópicos cobertos: estabilidade (antipatterns: cascading failures, blocked threads, chain reactions), patterns de resiliência (circuit breaker, bulkheads, timeouts, handshaking), capacity planning, administração de sistemas, monitoramento e observabilidade, telemetria, OpsDB, load testing, deployment zero-downtime, adaptação de software, SLIs/SLOs, dashboards executivos vs operacionais, arquitetura guiada por evidência.

## 5. DevOps

| Base | Itens | Conteúdo |
|:--|--:|:--|
| DevOps Knowledge Base | 4 | Livro e artigo |

Fontes: "Manual de DevOps" (Gene Kim), artigo sobre ArgoCD.

Tópicos cobertos: As Três Maneiras (Fluxo, Feedback, Aprendizado Contínuo), Lean e Teoria das Restrições, Manifesto Ágil, fluxos de valor, entrega contínua, Toyota Kata, Lei de Conway, integração de operações, telemetria, post-mortems sem culpa, segurança da informação integrada ao DevOps, gestão de mudanças, conformidade. ArgoCD para estabilidade e confiabilidade em GitOps.

## 6. Linux

| Base | Itens | Conteúdo |
|:--|--:|:--|
| Linux Knowledge Base | 4 | Livros técnicos |

Fontes: "Redes e Servidores Linux" (Carlos Morimoto), "Linux Utilities Cookbook" (James).

Tópicos cobertos: terminal/command line (bash, history, aliases, redirecionamento), desktop environments (GNOME, KDE, xfce, LXDE), arquivos e diretórios (find, grep, tar, zip), redes (troubleshooting, FTP, SCP, SSH, wget, httpd, IPv4/IPv6), permissões e segurança (useradd, SELinux, sudo, firewall), processos (ps, top, nice, /proc), discos e particionamento (fdisk, mkfs, fsck, LVM), scripting bash, redes e servidores (Arpanet, Ethernet, TCP/IP).

## 7. Firewall e Rede (pfSense)

| Base | Itens | Conteúdo |
|:--|--:|:--|
| pfSense Knowledge Base | 3 | Livros e guias |

Fontes: "Livro pfSense 2.0" (PT-BR), guia pfSense (Leonardo Damasceno).

Tópicos cobertos: instalação (LiveCD, Full Install, Embedded), interfaces de rede (LAN, WAN, DMZ, WiFi), regras de firewall (criação, edição, agendamento), aliases, NAT (Port Forward, 1:1, Outbound), IP Virtual (Proxy ARP, CARP, IP Alias), serviços integrados (DHCP, DNS Forwarder, Portal Captive), pacotes (Squid, Snort, FreeRadius, Nmap, NTop), VPN (PPTP, OpenVPN, IPSec), QoS/Traffic Shaper, Load Balance, FailOver, monitoramento (Traffic Graph, RRD Graphs, pfTop), logs do sistema, syslog externo, SMTP de notificação, backup/restore, requisitos de hardware.

## 8. ITSM e Chamados (GLPI)

| Base | Itens | Conteúdo |
|:--|--:|:--|
| GLPI Documentation | 1 | Documentação da API REST |
| GLPI API Guia Completo | 1 | Guia de interação com a API |

Tópicos cobertos: autenticação (initSession, killSession), gerenciamento de sessão (profiles, entities), operações CRUD (Get/Add/Update/Delete items), sub-items, busca (searchOptions, listSearchOptions), massive actions, paginação, expand_dropdowns, HATEOAS. Endpoints para Tickets, Users, Computers, Software, e demais itemtypes do GLPI.

## 9. Ferramentas Operacionais

| Base | Itens | Conteúdo |
|:--|--:|:--|
| Ferramentas Knowledge Base | 12 | Consolidado de ferramentas |
| Steampipe AWS Manual | 1 | Queries SQL para recursos AWS |
| Memos API Documentation | 1 | API do Memos (notas) |
| SSH Contexto | 1 | Contexto de acesso SSH |
| diagramas_aws | 1 | Templates de diagramas |

Tópicos cobertos:

Kiro CLI: cheat sheet completo (comandos, atalhos, agents, knowledge base, checkpoints, tangent mode, MCP, hooks, LSP, TUI).

Diagramas AWS: 20+ templates de arquitetura (enterprise multi-camada, serverless, streaming de mídia, SFTP multi-AZ, monitoramento com Grafana/Prometheus). Padrões SVG com ícones oficiais AWS.

Memos API: Activity Service, Attachment Service, Instance Service, Memo Service (CRUD completo, tags, filtros, paginação).

Steampipe: queries SQL para inventário e compliance AWS.

Avaliação MemPalace: análise de ferramenta de memória para agentes IA (benchmarks, decisão de não adoção, comparação com Zep/Mem0).

## 10. Relatórios e Templates

| Base | Itens | Conteúdo |
|:--|--:|:--|
| Relatórios Flexa | 2 | Template padrão de documentos PDF |

Tópicos cobertos: identidade visual, paleta de cores, estrutura de documento (capa, sumário dinâmico, capítulos), estilos tipográficos, tabelas, boxes de destaque, header/footer, script Python com reportlab para geração automatizada.

## 11. Carreira e Liderança

| Base | Itens | Conteúdo |
|:--|--:|:--|
| Carreira Knowledge Base | 2 | Artigos sobre liderança técnica |

Tópicos cobertos: papel do Tech Lead (arquitetura vs código, mentoria e delegação, comunicação com negócio, equilíbrio gestão/técnico 60/40, comunicação com alta gestão), gestão de squads por métricas, Staff Engineers, IA Fraca vs IA Forte, chapters como evolução da engenharia.

## 12. Memória Persistente

| Base | Itens | Conteúdo |
|:--|--:|:--|
| Kiro Memory | 1 | Estado atual da memória de sessão |
| Kiro Memory Skill | 1 | Documentação do sistema de memória |

Sistema de duas camadas: Hot (memory.md, 7 dias) + Cold (Memos, arquivo permanente). Comandos: salva memória, tarefa concluída, lembra disso, revisão semanal. Arquivamento automático com tags para busca.

## Estatísticas

| Métrica | Valor |
|:--|--:|
| Total de Knowledge Bases | 23 |
| Total de itens indexados | ~3.385 |
| Maior KB | Zabbix Training PDFs (1.661 itens) |
| Área com mais cobertura | Monitoramento (97,6% dos itens) |
| Formatos indexados | PDF, Markdown, YAML, JSON |
| Idiomas | Português (BR), Inglês |

## Distribuição por Área

```
Monitoramento (Zabbix)  ████████████████████████████████████████  97,6%
SRE                     █                                        0,6%
AWS                     █                                        0,6%
Ferramentas             █                                        0,5%
Docker/K8s              ░                                        0,2%
DevOps                  ░                                        0,1%
Linux                   ░                                        0,1%
pfSense                 ░                                        0,1%
Outros                  ░                                        0,2%
```

## Observações

1. A base é fortemente concentrada em Zabbix, o que reflete a operação principal de monitoramento
2. As áreas de AWS, SRE e DevOps possuem material de alta qualidade (livros de referência e guias consolidados), apesar do menor volume
3. O material de certificação AWS SAA-C03 inclui simulados com questões comentadas
4. A base de Docker inclui uma estrutura de curso completa em 9 módulos, pronta para uso em treinamentos
5. O conteúdo de pfSense é completo para operação de firewall em ambientes de pequeno e médio porte
6. Áreas com potencial de expansão: Terraform/IaC, Ansible, CI/CD (GitLab/GitHub Actions), Kubernetes avançado, segurança cloud
