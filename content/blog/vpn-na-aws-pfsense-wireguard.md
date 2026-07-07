---
title: "VPN na AWS: pfSense, WireGuard, Certificados e Integração com VPC"
date: 2026-07-17T08:00:00-03:00
description: |
  VPN na AWS vai muito além de "conectar dois pontos". Envolve routing, segurança e manutenção.

  O que cubro neste post:
  🔒 pfSense na AWS: OpenVPN e IPSec
  ⚡ WireGuard: alternativa moderna e mais leve
  🔑 Certificados x509 vs PSK: quando usar cada um
  🗺️ Route Tables da VPC: como rotear tráfego para a VPN
  🛡️ Segurança: rotação de credenciais, revogação, auditoria

  Qual VPN você usa no seu ambiente AWS?

  🔗 https://nerdseverino.com.br/blog/vpn-na-aws-pfsense-wireguard/

  #VPN #AWS #pfSense #WireGuard #SRE #Segurança #Rede
categories:
  - SRE
  - AWS
tags:
  - vpn
  - aws
  - pfsense
  - wireguard
  - segurança
  - rede
  - serie-sre-na-pratica
keywords:
  - vpn aws
  - pfsense aws
  - wireguard aws
  - certificados vpn
  - route table vpc
autoThumbnailImage: false
thumbnailImagePosition: top
---

VPN na AWS é uma das tarefas mais comuns e mais problemáticas de um SRE. Conectar escritórios, data centers e usuários remotos à VPC envolve decisões de protocolo, segurança de credenciais e integração com o roteamento da AWS.

<!--more-->

## Opções de VPN na AWS

| Solução | Tipo | Custo | Complexidade | Quando usar |
|---------|------|-------|-------------|-------------|
| AWS Site-to-Site VPN | Managed | ~$36/mês + tráfego | Baixa | Conexão permanente com escritório |
| pfSense em EC2 | Self-managed | Custo da EC2 | Alta | Controle total, features avançadas |
| WireGuard em EC2 | Self-managed | Custo da EC2 | Média | Simples, rápido, poucos usuários |
| AWS Client VPN | Managed | $0.10/conexão/hora | Baixa | Acesso remoto de usuários |

## pfSense na AWS

### Arquitetura

```
Internet → pfSense EC2 (WAN: EIP, LAN: subnet privada)
                ↓
         VPC Route Table → Subnets privadas
```

### OpenVPN no pfSense

Configuração do servidor:

| Parâmetro | Valor recomendado |
|-----------|-------------------|
| Protocol | UDP (mais rápido que TCP) |
| Port | 1194 (ou custom para evitar bloqueio) |
| Tunnel Network | 10.10.0.0/24 (diferente da VPC) |
| Local Network | 10.0.0.0/16 (CIDR da VPC) |
| Auth | Certificates (TLS) + User Auth |
| Encryption | AES-256-GCM |
| Hash | SHA256 |

### IPSec Site-to-Site

Para conexão permanente entre escritório e AWS:

| Parâmetro | Fase 1 (IKE) | Fase 2 (IPSec) |
|-----------|-------------|----------------|
| Encryption | AES-256 | AES-256 |
| Hash | SHA256 | SHA256 |
| DH Group | 14 (2048-bit) | 14 |
| Lifetime | 28800s (8h) | 3600s (1h) |
| Dead Peer Detection | Enabled | - |

## WireGuard

Alternativa moderna ao OpenVPN. Mais simples, mais rápido, menos código (4.000 linhas vs 100.000+ do OpenVPN).

### Instalação na EC2

```bash
sudo apt install wireguard

# Gerar chaves
wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key
chmod 600 /etc/wireguard/server_private.key
```

### Configuração do servidor

```ini
# /etc/wireguard/wg0.conf
[Interface]
Address = 10.20.0.1/24
ListenPort = 51820
PrivateKey = <server_private_key>

# Habilitar forwarding
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o ens5 -j MASQUERADE

[Peer]
# Cliente 1
PublicKey = <client_public_key>
AllowedIPs = 10.20.0.2/32
```

```bash
sudo systemctl enable --now wg-quick@wg0
```

### Configuração do cliente

```ini
[Interface]
Address = 10.20.0.2/32
PrivateKey = <client_private_key>
DNS = 10.0.0.2  # DNS da VPC

[Peer]
PublicKey = <server_public_key>
Endpoint = <EIP>:51820
AllowedIPs = 10.0.0.0/16, 10.20.0.0/24
PersistentKeepalive = 25
```

## Segurança de credenciais VPN

### Certificados x509 vs PSK

| Aspecto | Certificados (x509) | Pre-Shared Key (PSK) |
|---------|--------------------|-----------------------|
| Segurança | Alta (chave por usuário) | Média (chave compartilhada) |
| Revogação | Sim (CRL) | Não (trocar para todos) |
| Gestão | Complexa (CA, emissão, renovação) | Simples |
| Auditoria | Identifica quem conectou | Não identifica |
| Quando usar | Produção, múltiplos usuários | Lab, poucos usuários |

### CA própria (Easy-RSA)

```bash
# Inicializar CA
./easyrsa init-pki
./easyrsa build-ca

# Gerar certificado do servidor
./easyrsa gen-req server nopass
./easyrsa sign-req server server

# Gerar certificado do cliente
./easyrsa gen-req cliente1 nopass
./easyrsa sign-req client cliente1

# Revogar certificado (quando funcionário sai)
./easyrsa revoke cliente1
./easyrsa gen-crl
```

### Boas práticas

1. **Certificados individuais** por usuário (nunca compartilhar)
2. **Revogar imediatamente** quando alguém sai da empresa
3. **Validade curta** (1 ano) com renovação automática
4. **MFA** quando possível (OpenVPN + TOTP)
5. **Auditoria** de conexões (quem conectou, quando, de onde)

## Integração com VPC Route Tables

A VPN só funciona se o tráfego for roteado corretamente:

```
VPC Route Table (subnets privadas):
  10.0.0.0/16    → local (VPC)
  10.10.0.0/24   → eni-xxx (interface do pfSense/WireGuard)
  10.20.0.0/24   → eni-xxx (tunnel network)
  192.168.0.0/16 → eni-xxx (rede do escritório via VPN)
```

### Passos

1. **Desabilitar source/dest check** na EC2 da VPN
2. **Adicionar rotas** na route table das subnets que precisam acessar a VPN
3. **Security Groups**: permitir UDP 1194 (OpenVPN) ou 51820 (WireGuard) de 0.0.0.0/0
4. **Security Groups internos**: permitir tráfego da tunnel network (10.10.0.0/24 ou 10.20.0.0/24)

```bash
# Desabilitar source/dest check
aws ec2 modify-instance-attribute \
  --instance-id i-xxx \
  --no-source-dest-check

# Adicionar rota
aws ec2 create-route \
  --route-table-id rtb-xxx \
  --destination-cidr-block 192.168.0.0/16 \
  --instance-id i-xxx
```

## Troubleshooting

| Problema | Verificar |
|----------|-----------|
| VPN conecta mas não acessa VPC | Route table, source/dest check, Security Groups |
| VPN lenta | MTU (reduzir para 1400), UDP vs TCP |
| VPN desconecta periodicamente | DPD settings, keepalive, NAT timeout |
| Não resolve DNS da VPC | DNS da VPC (10.0.0.2), DHCP option set |
| pfSense não encaminha | `ip_forward`, `netstat -s -p ip`, versão do kernel |

```bash
# Verificar se forwarding está ativo
cat /proc/sys/net/ipv4/ip_forward  # Deve ser 1

# Verificar rotas no servidor VPN
ip route show

# Testar conectividade do tunnel
ping 10.10.0.1  # Gateway do tunnel
ping 10.0.0.x   # Host na VPC
```

---

*VPN na AWS parece simples até dar problema. A chave é: certificados individuais, route tables corretas, source/dest check desabilitado, e documentação de quem tem acesso. WireGuard para simplicidade, pfSense para controle total, AWS managed para quem não quer gerenciar.*
