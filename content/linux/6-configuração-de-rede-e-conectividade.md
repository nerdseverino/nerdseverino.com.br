---
title: 6 - Configuração de Rede e Conectividade
date: 2026-02-02T04:24:00.000Z
categories:
  - Curso
tags:
  - curso
  - linux
  - rede
  - networking
  - ssh
keywords:
  - linux
  - rede
  - networking
  - ssh
  - firewall
autoThumbnailImage: false
thumbnailImagePosition: top
coverImage: /images/uploads/9cbzwmsn.png
---

## Conceitos Básicos de Rede

### Modelo TCP/IP

```
Aplicação    → HTTP, SSH, FTP, DNS
Transporte   → TCP, UDP
Internet     → IP, ICMP
Enlace       → Ethernet, Wi-Fi
```

### Endereçamento IP

**IPv4**: 192.168.1.100
- Classes: A, B, C (privadas)
- Máscara de sub-rede: 255.255.255.0 (/24)

**IPv6**: 2001:0db8:85a3::8a2e:0370:7334
- Endereços de 128 bits
- Futuro da internet

### Portas Comuns

```
22   → SSH
80   → HTTP
443  → HTTPS
21   → FTP
25   → SMTP (email)
53   → DNS
3306 → MySQL
5432 → PostgreSQL
```

## Comandos de Diagnóstico

### ip - Gerenciamento de Rede Moderno

```bash
# Ver todas interfaces
ip addr show
ip a

# Ver interface específica
ip addr show eth0

# Ver rotas
ip route show
ip r

# Ver tabela ARP
ip neigh show

# Estatísticas de interface
ip -s link show eth0
```

### ifconfig - Comando Legado (ainda útil)

```bash
# Ver todas interfaces
ifconfig

# Ver interface específica
ifconfig eth0

# Ativar interface
sudo ifconfig eth0 up

# Desativar interface
sudo ifconfig eth0 down

# Configurar IP temporário
sudo ifconfig eth0 192.168.1.100 netmask 255.255.255.0
```

### ping - Testar Conectividade

```bash
# Ping básico
ping google.com

# Limitar número de pacotes
ping -c 4 google.com

# Intervalo entre pacotes
ping -i 2 google.com

# Ping IPv6
ping6 google.com

# Ping com timestamp
ping -D google.com
```

### traceroute - Rastrear Rota

```bash
# Instalar
sudo apt install traceroute

# Rastrear rota
traceroute google.com

# Usar ICMP em vez de UDP
sudo traceroute -I google.com

# Limitar hops
traceroute -m 15 google.com
```

### netstat - Estatísticas de Rede

```bash
# Todas conexões
netstat -a

# Portas em escuta
netstat -l

# Portas TCP em escuta
netstat -lt

# Portas UDP em escuta
netstat -lu

# Mostrar PIDs
sudo netstat -tulpn

# Estatísticas de interface
netstat -i

# Tabela de roteamento
netstat -r
```

### ss - Socket Statistics (substitui netstat)

```bash
# Todas conexões
ss -a

# Portas em escuta
ss -l

# TCP em escuta com PIDs
sudo ss -tlnp

# UDP em escuta
sudo ss -ulnp

# Conexões estabelecidas
ss -t state established

# Estatísticas resumidas
ss -s
```

### nmap - Network Scanner

```bash
# Instalar
sudo apt install nmap

# Scan básico
nmap 192.168.1.1

# Scan de rede
nmap 192.168.1.0/24

# Scan de portas específicas
nmap -p 22,80,443 192.168.1.1

# Scan completo
sudo nmap -A 192.168.1.1

# Detectar SO
sudo nmap -O 192.168.1.1

# Scan rápido
nmap -F 192.168.1.1
```

### dig - DNS Lookup

```bash
# Query DNS
dig google.com

# Query específico (A, MX, NS)
dig google.com A
dig google.com MX
dig google.com NS

# Servidor DNS específico
dig @8.8.8.8 google.com

# Resposta curta
dig +short google.com

# Reverse DNS
dig -x 8.8.8.8
```

### nslookup - DNS Query

```bash
# Query básico
nslookup google.com

# Servidor DNS específico
nslookup google.com 8.8.8.8

# Modo interativo
nslookup
> server 8.8.8.8
> google.com
> exit
```

### host - DNS Lookup Simples

```bash
# Query básico
host google.com

# Tipo específico
host -t MX google.com
host -t NS google.com

# Reverse lookup
host 8.8.8.8
```

## Configuração de Rede

### NetworkManager (Desktop)

```bash
# Status
nmcli general status

# Ver conexões
nmcli connection show

# Ver dispositivos
nmcli device status

# Conectar Wi-Fi
nmcli device wifi list
nmcli device wifi connect SSID password SENHA

# Configurar IP estático
nmcli connection modify eth0 \
  ipv4.addresses 192.168.1.100/24 \
  ipv4.gateway 192.168.1.1 \
  ipv4.dns "8.8.8.8 8.8.4.4" \
  ipv4.method manual

# Aplicar mudanças
nmcli connection up eth0

# DHCP
nmcli connection modify eth0 ipv4.method auto
nmcli connection up eth0
```

### Netplan (Ubuntu 18.04+)

```bash
# Arquivo de configuração
sudo vim /etc/netplan/01-netcfg.yaml
```

**DHCP:**
```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
```

**IP Estático:**
```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

**Aplicar:**
```bash
sudo netplan apply
```

### /etc/network/interfaces (Debian/Ubuntu antigo)

```bash
sudo vim /etc/network/interfaces
```

**DHCP:**
```
auto eth0
iface eth0 inet dhcp
```

**IP Estático:**
```
auto eth0
iface eth0 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4
```

**Reiniciar:**
```bash
sudo systemctl restart networking
```

### systemd-networkd (Servidor)

```bash
# Arquivo de configuração
sudo vim /etc/systemd/network/20-wired.network
```

**Conteúdo:**
```ini
[Match]
Name=eth0

[Network]
Address=192.168.1.100/24
Gateway=192.168.1.1
DNS=8.8.8.8
DNS=8.8.4.4
```

**Habilitar:**
```bash
sudo systemctl enable systemd-networkd
sudo systemctl start systemd-networkd
```

## DNS

### Configurar Servidores DNS

**Método 1: /etc/resolv.conf**
```bash
sudo vim /etc/resolv.conf
```

```
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
```

**Método 2: systemd-resolved**
```bash
sudo vim /etc/systemd/resolved.conf
```

```ini
[Resolve]
DNS=8.8.8.8 8.8.4.4
FallbackDNS=1.1.1.1
```

```bash
sudo systemctl restart systemd-resolved
```

### /etc/hosts - Resolução Local

```bash
sudo vim /etc/hosts
```

```
127.0.0.1       localhost
192.168.1.10    servidor.local servidor
192.168.1.20    web.local
```

## SSH - Secure Shell

### Cliente SSH

```bash
# Conectar
ssh usuario@servidor.com

# Porta específica
ssh -p 2222 usuario@servidor.com

# Executar comando remoto
ssh usuario@servidor.com 'ls -la'

# Copiar chave pública
ssh-copy-id usuario@servidor.com

# Túnel SSH (port forwarding)
ssh -L 8080:localhost:80 usuario@servidor.com

# Túnel reverso
ssh -R 8080:localhost:80 usuario@servidor.com

# Proxy SOCKS
ssh -D 1080 usuario@servidor.com

# Manter conexão viva
ssh -o ServerAliveInterval=60 usuario@servidor.com
```

### Gerar Chaves SSH

```bash
# Gerar par de chaves
ssh-keygen -t ed25519 -C "seu@email.com"

# Ou RSA 4096
ssh-keygen -t rsa -b 4096 -C "seu@email.com"

# Chaves ficam em:
# ~/.ssh/id_ed25519 (privada)
# ~/.ssh/id_ed25519.pub (pública)

# Permissões corretas
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
chmod 644 ~/.ssh/authorized_keys
```

### Configurar Servidor SSH

```bash
# Instalar
sudo apt install openssh-server

# Configuração
sudo vim /etc/ssh/sshd_config
```

**Configurações importantes:**
```
Port 22
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
X11Forwarding no
AllowUsers usuario1 usuario2
```

**Reiniciar:**
```bash
sudo systemctl restart sshd
```

### SSH Config (~/.ssh/config)

```bash
vim ~/.ssh/config
```

```
Host servidor
    HostName servidor.com
    User usuario
    Port 2222
    IdentityFile ~/.ssh/id_ed25519

Host *.empresa.com
    User admin
    ForwardAgent yes
    
Host bastion
    HostName bastion.empresa.com
    User admin
    
Host interno
    HostName 10.0.1.100
    User root
    ProxyJump bastion
```

**Usar:**
```bash
ssh servidor
ssh interno  # Conecta via bastion
```

## SCP e RSYNC - Transferência de Arquivos

### scp - Secure Copy

```bash
# Copiar para servidor
scp arquivo.txt usuario@servidor.com:/caminho/

# Copiar do servidor
scp usuario@servidor.com:/caminho/arquivo.txt .

# Copiar diretório
scp -r pasta/ usuario@servidor.com:/caminho/

# Porta específica
scp -P 2222 arquivo.txt usuario@servidor.com:/caminho/

# Preservar atributos
scp -p arquivo.txt usuario@servidor.com:/caminho/
```

### rsync - Sincronização Eficiente

```bash
# Sincronizar diretório
rsync -av origem/ destino/

# Sincronizar via SSH
rsync -av origem/ usuario@servidor.com:/destino/

# Mostrar progresso
rsync -av --progress origem/ destino/

# Deletar arquivos no destino que não existem na origem
rsync -av --delete origem/ destino/

# Excluir arquivos
rsync -av --exclude='*.log' origem/ destino/

# Dry run (simular)
rsync -av --dry-run origem/ destino/

# Backup incremental
rsync -av --link-dest=/backup/anterior origem/ /backup/novo/
```

## Firewall

### UFW - Uncomplicated Firewall (Ubuntu)

```bash
# Instalar
sudo apt install ufw

# Status
sudo ufw status

# Habilitar
sudo ufw enable

# Desabilitar
sudo ufw disable

# Permitir porta
sudo ufw allow 22
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Permitir de IP específico
sudo ufw allow from 192.168.1.100

# Permitir porta de IP específico
sudo ufw allow from 192.168.1.100 to any port 22

# Negar porta
sudo ufw deny 23

# Deletar regra
sudo ufw delete allow 80

# Resetar firewall
sudo ufw reset

# Regras numeradas
sudo ufw status numbered
sudo ufw delete 2
```

### firewalld (Fedora/RHEL/CentOS)

```bash
# Status
sudo firewall-cmd --state

# Zonas
sudo firewall-cmd --get-zones
sudo firewall-cmd --get-default-zone

# Listar regras
sudo firewall-cmd --list-all

# Permitir serviço
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent

# Permitir porta
sudo firewall-cmd --add-port=8080/tcp --permanent

# Remover porta
sudo firewall-cmd --remove-port=8080/tcp --permanent

# Recarregar
sudo firewall-cmd --reload

# Zona específica
sudo firewall-cmd --zone=public --add-service=ssh --permanent
```

### iptables - Firewall de Baixo Nível

```bash
# Listar regras
sudo iptables -L -n -v

# Permitir porta
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Bloquear IP
sudo iptables -A INPUT -s 192.168.1.100 -j DROP

# Permitir conexões estabelecidas
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Bloquear tudo exceto regras
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# Salvar regras
sudo iptables-save > /etc/iptables/rules.v4

# Restaurar regras
sudo iptables-restore < /etc/iptables/rules.v4
```

## VPN

### OpenVPN Cliente

```bash
# Instalar
sudo apt install openvpn

# Conectar
sudo openvpn --config cliente.ovpn

# Como serviço
sudo cp cliente.ovpn /etc/openvpn/cliente.conf
sudo systemctl start openvpn@cliente
sudo systemctl enable openvpn@cliente
```

### WireGuard

```bash
# Instalar
sudo apt install wireguard

# Gerar chaves
wg genkey | tee privatekey | wg pubkey > publickey

# Configuração
sudo vim /etc/wireguard/wg0.conf
```

```ini
[Interface]
PrivateKey = CHAVE_PRIVADA
Address = 10.0.0.2/24

[Peer]
PublicKey = CHAVE_PUBLICA_SERVIDOR
Endpoint = servidor.com:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

```bash
# Iniciar
sudo wg-quick up wg0

# Parar
sudo wg-quick down wg0

# Status
sudo wg show

# Habilitar no boot
sudo systemctl enable wg-quick@wg0
```

## Troubleshooting de Rede

### Sem Conectividade

```bash
# 1. Verificar interface
ip link show

# 2. Verificar IP
ip addr show

# 3. Verificar gateway
ip route show

# 4. Testar gateway
ping 192.168.1.1

# 5. Testar DNS
ping 8.8.8.8

# 6. Testar resolução DNS
ping google.com

# 7. Verificar DNS
cat /etc/resolv.conf
```

### Porta não Acessível

```bash
# Verificar se serviço está rodando
sudo systemctl status nginx

# Verificar se porta está em escuta
sudo ss -tlnp | grep :80

# Verificar firewall
sudo ufw status
sudo firewall-cmd --list-all

# Testar localmente
curl localhost:80

# Testar remotamente
telnet servidor.com 80
nc -zv servidor.com 80
```

### DNS não Resolve

```bash
# Testar DNS
dig google.com
nslookup google.com

# Verificar /etc/resolv.conf
cat /etc/resolv.conf

# Testar DNS alternativo
dig @8.8.8.8 google.com

# Limpar cache DNS
sudo systemd-resolve --flush-caches
```

### Lentidão de Rede

```bash
# Testar velocidade
speedtest-cli

# Verificar latência
ping -c 100 google.com | tail -1

# Verificar perda de pacotes
mtr google.com

# Verificar uso de banda
sudo apt install iftop
sudo iftop -i eth0
```

## Monitoramento de Rede

### iftop - Uso de Banda em Tempo Real

```bash
sudo apt install iftop
sudo iftop -i eth0
```

### nethogs - Uso por Processo

```bash
sudo apt install nethogs
sudo nethogs eth0
```

### vnstat - Estatísticas de Tráfego

```bash
sudo apt install vnstat

# Habilitar
sudo systemctl enable vnstat
sudo systemctl start vnstat

# Ver estatísticas
vnstat
vnstat -d  # Diário
vnstat -m  # Mensal
vnstat -h  # Por hora
```

## Comandos de Referência Rápida

```bash
# Ver IPs
ip addr show

# Ver rotas
ip route show

# Testar conectividade
ping google.com

# Portas em escuta
sudo ss -tlnp

# DNS lookup
dig google.com

# Conectar SSH
ssh usuario@servidor.com

# Copiar arquivo
scp arquivo.txt usuario@servidor:/caminho/

# Sincronizar diretório
rsync -av origem/ destino/

# Firewall (Ubuntu)
sudo ufw allow 80

# Firewall (Fedora)
sudo firewall-cmd --add-port=80/tcp --permanent
```

---

**Próximo capítulo**: 7 - Uso Avançado do Terminal e Scripts

**Capítulo anterior**: [5 - Gerenciamento de Pacotes](https://www.nerdseverino.com.br/linux/5-gerenciamento-de-pacotes-e-software/)
