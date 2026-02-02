---
title: 8 - Segurança no Linux
date: 2026-02-02T04:24:00.000Z
categories:
  - Curso
tags:
  - curso
  - linux
  - seguranca
  - hardening
keywords:
  - linux
  - seguranca
  - hardening
  - firewall
  - selinux
autoThumbnailImage: false
thumbnailImagePosition: top
coverImage: /images/uploads/9cbzwmsn.png
---

## Princípios de Segurança

### Defesa em Profundidade

Múltiplas camadas de segurança:
1. Firewall
2. Autenticação forte
3. Permissões adequadas
4. Atualizações regulares
5. Monitoramento
6. Backup

### Princípio do Menor Privilégio

Usuários e processos devem ter apenas as permissões necessárias.

## Gerenciamento de Usuários

### Criar Usuário

```bash
# Criar usuário
sudo useradd -m -s /bin/bash usuario

# Definir senha
sudo passwd usuario

# Criar com home e grupos
sudo useradd -m -G sudo,docker -s /bin/bash usuario

# Criar usuário de sistema (sem login)
sudo useradd -r -s /usr/sbin/nologin servico
```

### Modificar Usuário

```bash
# Adicionar a grupo
sudo usermod -aG sudo usuario

# Mudar shell
sudo usermod -s /bin/zsh usuario

# Bloquear usuário
sudo usermod -L usuario

# Desbloquear
sudo usermod -U usuario

# Expirar senha
sudo passwd -e usuario
```

### Deletar Usuário

```bash
# Deletar usuário (mantém home)
sudo userdel usuario

# Deletar com home
sudo userdel -r usuario
```

### Gerenciar Grupos

```bash
# Criar grupo
sudo groupadd developers

# Adicionar usuário a grupo
sudo usermod -aG developers usuario

# Ver grupos do usuário
groups usuario

# Deletar grupo
sudo groupdel developers
```

### Arquivos Importantes

```bash
# Usuários
/etc/passwd

# Senhas (hash)
/etc/shadow

# Grupos
/etc/group

# Configuração padrão
/etc/login.defs
/etc/default/useradd
```

## Sudo - Privilégios Administrativos

### Configurar sudo

```bash
# Editar sudoers (SEMPRE use visudo)
sudo visudo
```

**Exemplos:**
```
# Usuário com sudo total
usuario ALL=(ALL:ALL) ALL

# Grupo com sudo
%admin ALL=(ALL:ALL) ALL

# Sem senha
usuario ALL=(ALL) NOPASSWD: ALL

# Comandos específicos
usuario ALL=(ALL) /usr/bin/systemctl, /usr/bin/apt

# Executar como outro usuário
usuario ALL=(www-data) /usr/bin/php
```

### Usar sudo

```bash
# Executar comando
sudo comando

# Shell root
sudo -i
sudo su -

# Executar como outro usuário
sudo -u www-data comando

# Listar privilégios
sudo -l

# Editar arquivo com privilégios
sudo -e /etc/hosts
```

## Autenticação

### Políticas de Senha

```bash
# Instalar PAM
sudo apt install libpam-pwquality

# Configurar
sudo vim /etc/security/pwquality.conf
```

```
# Tamanho mínimo
minlen = 12

# Complexidade
minclass = 3
dcredit = -1  # Pelo menos 1 dígito
ucredit = -1  # Pelo menos 1 maiúscula
lcredit = -1  # Pelo menos 1 minúscula
ocredit = -1  # Pelo menos 1 caractere especial

# Rejeitar senhas comuns
dictcheck = 1
```

### Expiração de Senha

```bash
# Configurar expiração
sudo chage -M 90 usuario  # Expira em 90 dias
sudo chage -m 7 usuario   # Mínimo 7 dias entre mudanças
sudo chage -W 14 usuario  # Avisar 14 dias antes

# Ver configuração
sudo chage -l usuario

# Forçar mudança no próximo login
sudo chage -d 0 usuario
```

### Autenticação de Dois Fatores (2FA)

```bash
# Instalar Google Authenticator
sudo apt install libpam-google-authenticator

# Configurar para usuário
google-authenticator

# Habilitar no SSH
sudo vim /etc/pam.d/sshd
```

Adicionar:
```
auth required pam_google_authenticator.so
```

```bash
# Configurar SSH
sudo vim /etc/ssh/sshd_config
```

```
ChallengeResponseAuthentication yes
AuthenticationMethods publickey,keyboard-interactive
```

```bash
sudo systemctl restart sshd
```

## SSH Hardening

### Configuração Segura

```bash
sudo vim /etc/ssh/sshd_config
```

```
# Porta não padrão
Port 2222

# Apenas protocolo 2
Protocol 2

# Desabilitar root login
PermitRootLogin no

# Apenas chaves públicas
PasswordAuthentication no
PubkeyAuthentication yes

# Desabilitar autenticação vazia
PermitEmptyPasswords no

# Limitar usuários
AllowUsers usuario1 usuario2

# Timeout
ClientAliveInterval 300
ClientAliveCountMax 2

# Desabilitar X11 forwarding
X11Forwarding no

# Desabilitar port forwarding
AllowTcpForwarding no
```

### Fail2ban - Proteção contra Brute Force

```bash
# Instalar
sudo apt install fail2ban

# Configurar
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo vim /etc/fail2ban/jail.local
```

```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = 2222
logpath = /var/log/auth.log
```

```bash
# Iniciar
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Status
sudo fail2ban-client status
sudo fail2ban-client status sshd

# Desbanir IP
sudo fail2ban-client set sshd unbanip 192.168.1.100
```

## Firewall

### UFW (Ubuntu)

```bash
# Configuração básica
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Permitir SSH
sudo ufw allow 22/tcp

# Permitir de IP específico
sudo ufw allow from 192.168.1.100 to any port 22

# Habilitar
sudo ufw enable

# Status
sudo ufw status verbose
```

### firewalld (Fedora/RHEL)

```bash
# Configuração básica
sudo firewall-cmd --set-default-zone=public

# Permitir serviços
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https

# Recarregar
sudo firewall-cmd --reload
```

## SELinux (Security-Enhanced Linux)

### Status

```bash
# Ver status
sestatus
getenforce

# Modos: Enforcing, Permissive, Disabled
```

### Configurar

```bash
# Temporário
sudo setenforce 0  # Permissive
sudo setenforce 1  # Enforcing

# Permanente
sudo vim /etc/selinux/config
```

```
SELINUX=enforcing
```

### Troubleshooting

```bash
# Ver alertas
sudo ausearch -m avc -ts recent

# Gerar política
sudo audit2allow -a -M mypolicy
sudo semodule -i mypolicy.pp

# Contextos
ls -Z arquivo
ps -eZ
```

## AppArmor (Ubuntu)

### Status

```bash
# Ver status
sudo aa-status

# Perfis em enforce
sudo aa-enforce /etc/apparmor.d/usr.bin.firefox

# Perfis em complain (log only)
sudo aa-complain /etc/apparmor.d/usr.bin.firefox

# Desabilitar perfil
sudo aa-disable /etc/apparmor.d/usr.bin.firefox
```

## Auditoria e Logs

### Logs Importantes

```bash
# Autenticação
/var/log/auth.log      # Debian/Ubuntu
/var/log/secure        # RHEL/CentOS

# Sistema
/var/log/syslog        # Debian/Ubuntu
/var/log/messages      # RHEL/CentOS

# Kernel
/var/log/kern.log
dmesg

# Aplicações
/var/log/apache2/
/var/log/nginx/
/var/log/mysql/
```

### Monitorar Logs

```bash
# Tempo real
tail -f /var/log/auth.log

# Últimas 100 linhas
tail -100 /var/log/syslog

# Buscar padrões
grep "Failed password" /var/log/auth.log

# Contar tentativas falhas
grep "Failed password" /var/log/auth.log | wc -l
```

### journalctl (systemd)

```bash
# Ver todos logs
journalctl

# Últimas 100 linhas
journalctl -n 100

# Tempo real
journalctl -f

# Desde boot
journalctl -b

# Serviço específico
journalctl -u ssh

# Prioridade (err, warning, info)
journalctl -p err

# Período
journalctl --since "2026-02-01" --until "2026-02-02"
journalctl --since "1 hour ago"

# Usuário específico
journalctl _UID=1000
```

### auditd - Auditoria Avançada

```bash
# Instalar
sudo apt install auditd

# Regras
sudo vim /etc/audit/rules.d/audit.rules
```

```
# Monitorar arquivo
-w /etc/passwd -p wa -k passwd_changes

# Monitorar diretório
-w /etc/ssh/ -p wa -k ssh_config

# Monitorar syscalls
-a always,exit -F arch=b64 -S open -S openat -k file_access
```

```bash
# Recarregar regras
sudo augenrules --load

# Buscar eventos
sudo ausearch -k passwd_changes

# Relatório
sudo aureport
```

## Criptografia

### Criptografar Arquivos

```bash
# GPG - criptografar
gpg -c arquivo.txt
# Cria: arquivo.txt.gpg

# Descriptografar
gpg arquivo.txt.gpg

# Criptografar para destinatário
gpg -e -r destinatario@email.com arquivo.txt

# Assinar arquivo
gpg --sign arquivo.txt
```

### Criptografar Partições (LUKS)

```bash
# Criar partição criptografada
sudo cryptsetup luksFormat /dev/sdb1

# Abrir
sudo cryptsetup luksOpen /dev/sdb1 dados_criptografados

# Formatar
sudo mkfs.ext4 /dev/mapper/dados_criptografados

# Montar
sudo mount /dev/mapper/dados_criptografados /mnt/dados

# Desmontar e fechar
sudo umount /mnt/dados
sudo cryptsetup luksClose dados_criptografados
```

## Hardening do Sistema

### 1. Atualizações Automáticas

```bash
# Ubuntu
sudo apt install unattended-upgrades
sudo dpkg-reconfigure unattended-upgrades

# Fedora
sudo dnf install dnf-automatic
sudo systemctl enable --now dnf-automatic.timer
```

### 2. Desabilitar Serviços Desnecessários

```bash
# Listar serviços
systemctl list-unit-files --type=service

# Desabilitar
sudo systemctl disable bluetooth
sudo systemctl stop bluetooth
```

### 3. Kernel Hardening (sysctl)

```bash
sudo vim /etc/sysctl.d/99-hardening.conf
```

```ini
# Proteção contra IP spoofing
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Ignorar ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0

# Não enviar ICMP redirects
net.ipv4.conf.all.send_redirects = 0

# Ignorar ping
net.ipv4.icmp_echo_ignore_all = 1

# SYN cookies (proteção contra SYN flood)
net.ipv4.tcp_syncookies = 1

# Desabilitar IPv6 (se não usado)
net.ipv6.conf.all.disable_ipv6 = 1
```

```bash
# Aplicar
sudo sysctl -p /etc/sysctl.d/99-hardening.conf
```

### 4. Limitar Core Dumps

```bash
sudo vim /etc/security/limits.conf
```

```
* hard core 0
```

### 5. Proteger GRUB

```bash
# Gerar senha
grub-mkpasswd-pbkdf2

# Configurar
sudo vim /etc/grub.d/40_custom
```

```
set superusers="admin"
password_pbkdf2 admin HASH_GERADO
```

```bash
sudo update-grub
```

## Detecção de Intrusão

### AIDE - Advanced Intrusion Detection

```bash
# Instalar
sudo apt install aide

# Inicializar banco de dados
sudo aideinit

# Verificar integridade
sudo aide --check

# Atualizar banco de dados
sudo aide --update
```

### rkhunter - Rootkit Hunter

```bash
# Instalar
sudo apt install rkhunter

# Atualizar
sudo rkhunter --update

# Scan
sudo rkhunter --check

# Atualizar propriedades
sudo rkhunter --propupd
```

### ClamAV - Antivírus

```bash
# Instalar
sudo apt install clamav clamav-daemon

# Atualizar definições
sudo freshclam

# Scan
clamscan -r /home

# Scan com remoção
clamscan -r --remove /home
```

## Backup e Recuperação

### Backup com tar

```bash
# Backup completo
sudo tar czf backup_$(date +%Y%m%d).tar.gz /home /etc

# Backup incremental
sudo tar czf backup_inc.tar.gz --listed-incremental=snapshot.file /home

# Restaurar
sudo tar xzf backup.tar.gz -C /
```

### rsync para Backup

```bash
# Backup local
rsync -av --delete /origem/ /backup/

# Backup remoto
rsync -av --delete /origem/ usuario@servidor:/backup/

# Backup incremental
rsync -av --link-dest=/backup/anterior /origem/ /backup/novo/
```

## Checklist de Segurança

### Sistema

- [ ] Atualizações automáticas habilitadas
- [ ] Serviços desnecessários desabilitados
- [ ] Firewall configurado
- [ ] SELinux/AppArmor habilitado
- [ ] Kernel hardening aplicado

### Usuários

- [ ] Root login desabilitado
- [ ] Política de senhas forte
- [ ] Sudo configurado corretamente
- [ ] Usuários desnecessários removidos

### SSH

- [ ] Porta não padrão
- [ ] Apenas chaves públicas
- [ ] Fail2ban configurado
- [ ] 2FA habilitado (opcional)

### Monitoramento

- [ ] Logs centralizados
- [ ] Auditoria habilitada
- [ ] Alertas configurados
- [ ] Backup regular

### Rede

- [ ] Firewall ativo
- [ ] Portas desnecessárias fechadas
- [ ] VPN para acesso remoto
- [ ] IDS/IPS configurado (opcional)

## Comandos de Referência Rápida

```bash
# Criar usuário
sudo useradd -m -s /bin/bash usuario

# Adicionar a sudo
sudo usermod -aG sudo usuario

# Configurar firewall
sudo ufw enable
sudo ufw allow 22

# Ver logs de autenticação
sudo tail -f /var/log/auth.log

# Verificar portas abertas
sudo ss -tlnp

# Atualizar sistema
sudo apt update && sudo apt upgrade

# Scan de rootkits
sudo rkhunter --check

# Backup
sudo tar czf backup.tar.gz /home
```

---

**Próximo capítulo**: 9 - Administração Avançada e Troubleshooting

**Capítulo anterior**: [7 - Scripts e Terminal Avançado](https://www.nerdseverino.com.br/linux/7-uso-avan%C3%A7ado-do-terminal-e-scripts/)
