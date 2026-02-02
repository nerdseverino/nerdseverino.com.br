---
title: 9 - Administração Avançada e Troubleshooting
date: 2026-02-02T04:24:00.000Z
categories:
  - Curso
tags:
  - curso
  - linux
  - administracao
  - troubleshooting
  - sysadmin
keywords:
  - linux
  - administracao
  - troubleshooting
  - systemd
  - performance
autoThumbnailImage: false
thumbnailImagePosition: top
coverImage: /images/uploads/9cbzwmsn.png
---

## Gerenciamento de Processos

### ps - Process Status

```bash
# Todos processos
ps aux

# Processos do usuário
ps -u usuario

# Árvore de processos
ps auxf
pstree

# Processos por CPU
ps aux --sort=-%cpu | head

# Processos por memória
ps aux --sort=-%mem | head

# Informações específicas
ps -eo pid,user,cmd,%cpu,%mem
```

### top - Monitor em Tempo Real

```bash
# Iniciar top
top

# Comandos dentro do top:
# h - ajuda
# k - matar processo
# r - renice processo
# M - ordenar por memória
# P - ordenar por CPU
# q - sair
```

### htop - Top Melhorado

```bash
# Instalar
sudo apt install htop

# Executar
htop

# Recursos:
# F2 - configuração
# F3 - buscar
# F4 - filtrar
# F5 - árvore
# F6 - ordenar
# F9 - matar
# F10 - sair
```

### kill - Terminar Processos

```bash
# Matar por PID
kill 1234

# Forçar término
kill -9 1234
kill -SIGKILL 1234

# Término gracioso
kill -15 1234
kill -SIGTERM 1234

# Matar por nome
killall firefox
pkill firefox

# Matar processos do usuário
pkill -u usuario
```

### nice e renice - Prioridade

```bash
# Iniciar com prioridade (-20 a 19, menor = maior prioridade)
nice -n 10 comando

# Alterar prioridade
renice -n 5 -p 1234

# Prioridade por usuário
renice -n 10 -u usuario
```

### Processos em Background

```bash
# Executar em background
comando &

# Listar jobs
jobs

# Trazer para foreground
fg %1

# Enviar para background
bg %1

# Suspender processo (Ctrl+Z)
# Depois: bg para continuar em background

# Desassociar do terminal
nohup comando &
```

## systemd - Gerenciamento de Serviços

### systemctl - Controle de Serviços

```bash
# Status do serviço
systemctl status nginx

# Iniciar serviço
sudo systemctl start nginx

# Parar serviço
sudo systemctl stop nginx

# Reiniciar serviço
sudo systemctl restart nginx

# Recarregar configuração
sudo systemctl reload nginx

# Habilitar no boot
sudo systemctl enable nginx

# Desabilitar no boot
sudo systemctl disable nginx

# Verificar se está habilitado
systemctl is-enabled nginx

# Verificar se está ativo
systemctl is-active nginx
```

### Listar Serviços

```bash
# Todos serviços
systemctl list-units --type=service

# Serviços ativos
systemctl list-units --type=service --state=active

# Serviços que falharam
systemctl list-units --type=service --state=failed

# Serviços habilitados
systemctl list-unit-files --type=service --state=enabled
```

### Criar Serviço Customizado

```bash
sudo vim /etc/systemd/system/meuapp.service
```

```ini
[Unit]
Description=Minha Aplicação
After=network.target

[Service]
Type=simple
User=usuario
WorkingDirectory=/opt/meuapp
ExecStart=/opt/meuapp/start.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
# Recarregar systemd
sudo systemctl daemon-reload

# Habilitar e iniciar
sudo systemctl enable meuapp
sudo systemctl start meuapp
```

### Targets (Runlevels)

```bash
# Ver target atual
systemctl get-default

# Mudar target padrão
sudo systemctl set-default multi-user.target

# Targets comuns:
# poweroff.target (runlevel 0)
# rescue.target (runlevel 1)
# multi-user.target (runlevel 3)
# graphical.target (runlevel 5)
# reboot.target (runlevel 6)

# Mudar para target
sudo systemctl isolate multi-user.target
```

## Gerenciamento de Disco

### df - Disk Free

```bash
# Espaço em disco
df -h

# Inodes
df -i

# Tipo de filesystem
df -T
```

### du - Disk Usage

```bash
# Tamanho do diretório
du -sh /var

# Top 10 maiores diretórios
du -h /var | sort -rh | head -10

# Tamanho de cada subdiretório
du -h --max-depth=1 /var
```

### lsblk - Listar Dispositivos de Bloco

```bash
# Listar dispositivos
lsblk

# Com filesystem
lsblk -f

# Tamanhos em bytes
lsblk -b
```

### fdisk - Particionar Disco

```bash
# Listar partições
sudo fdisk -l

# Particionar disco
sudo fdisk /dev/sdb

# Comandos dentro do fdisk:
# m - ajuda
# p - listar partições
# n - nova partição
# d - deletar partição
# w - salvar e sair
# q - sair sem salvar
```

### Formatar Partição

```bash
# ext4
sudo mkfs.ext4 /dev/sdb1

# xfs
sudo mkfs.xfs /dev/sdb1

# btrfs
sudo mkfs.btrfs /dev/sdb1

# Com label
sudo mkfs.ext4 -L dados /dev/sdb1
```

### Montar Filesystem

```bash
# Montar temporário
sudo mount /dev/sdb1 /mnt

# Desmontar
sudo umount /mnt

# Montar permanente (/etc/fstab)
sudo vim /etc/fstab
```

```
# <device>    <mount>    <type>  <options>       <dump> <pass>
/dev/sdb1     /dados     ext4    defaults        0      2
UUID=xxx      /backup    ext4    defaults,noatime 0     2
```

```bash
# Montar tudo do fstab
sudo mount -a

# Ver UUID
sudo blkid
```

### LVM - Logical Volume Manager

```bash
# Criar Physical Volume
sudo pvcreate /dev/sdb1

# Criar Volume Group
sudo vgcreate vg_dados /dev/sdb1

# Criar Logical Volume
sudo lvcreate -L 10G -n lv_dados vg_dados

# Formatar
sudo mkfs.ext4 /dev/vg_dados/lv_dados

# Montar
sudo mount /dev/vg_dados/lv_dados /dados

# Estender LV
sudo lvextend -L +5G /dev/vg_dados/lv_dados
sudo resize2fs /dev/vg_dados/lv_dados

# Ver informações
sudo pvdisplay
sudo vgdisplay
sudo lvdisplay
```

### RAID

```bash
# Criar RAID 1 (espelhamento)
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1

# Ver status
cat /proc/mdstat
sudo mdadm --detail /dev/md0

# Salvar configuração
sudo mdadm --detail --scan >> /etc/mdadm/mdadm.conf
```

## Monitoramento de Performance

### vmstat - Virtual Memory Statistics

```bash
# Estatísticas a cada 2 segundos
vmstat 2

# 10 amostras
vmstat 2 10
```

### iostat - I/O Statistics

```bash
# Instalar
sudo apt install sysstat

# Estatísticas de I/O
iostat

# Detalhado
iostat -x

# A cada 2 segundos
iostat -x 2
```

### iotop - I/O por Processo

```bash
# Instalar
sudo apt install iotop

# Executar
sudo iotop
```

### sar - System Activity Reporter

```bash
# CPU
sar -u 2 10

# Memória
sar -r 2 10

# I/O
sar -b 2 10

# Rede
sar -n DEV 2 10

# Histórico (requer sysstat habilitado)
sar -u -f /var/log/sysstat/sa01
```

### free - Memória

```bash
# Uso de memória
free -h

# Atualizar a cada 2 segundos
free -h -s 2
```

### uptime - Tempo de Atividade

```bash
# Uptime e load average
uptime

# Load average: 1min, 5min, 15min
# Ideal: < número de CPUs
```

## Troubleshooting Comum

### Sistema Lento

```bash
# 1. Verificar load average
uptime

# 2. Verificar CPU
top
htop

# 3. Verificar memória
free -h

# 4. Verificar disco
df -h
iostat -x

# 5. Verificar processos
ps aux --sort=-%cpu | head
ps aux --sort=-%mem | head

# 6. Verificar I/O
sudo iotop
```

### Disco Cheio

```bash
# 1. Verificar uso
df -h

# 2. Encontrar maiores diretórios
sudo du -h / | sort -rh | head -20

# 3. Encontrar arquivos grandes
sudo find / -type f -size +100M -exec ls -lh {} \;

# 4. Limpar logs
sudo journalctl --vacuum-time=7d
sudo find /var/log -name "*.log" -mtime +30 -delete

# 5. Limpar cache de pacotes
sudo apt clean
sudo dnf clean all

# 6. Remover pacotes órfãos
sudo apt autoremove
```

### Processo Travado

```bash
# 1. Identificar PID
ps aux | grep processo

# 2. Ver detalhes
sudo lsof -p PID
sudo strace -p PID

# 3. Tentar término gracioso
kill PID

# 4. Forçar término
kill -9 PID

# 5. Se não funcionar, verificar estado
ps aux | grep PID
# Estado D (uninterruptible sleep) = problema de I/O
```

### Rede não Funciona

```bash
# 1. Verificar interface
ip link show

# 2. Verificar IP
ip addr show

# 3. Verificar rota
ip route show

# 4. Testar gateway
ping 192.168.1.1

# 5. Testar DNS
ping 8.8.8.8
ping google.com

# 6. Verificar DNS
cat /etc/resolv.conf

# 7. Reiniciar rede
sudo systemctl restart NetworkManager
```

### Serviço não Inicia

```bash
# 1. Ver status
sudo systemctl status servico

# 2. Ver logs
sudo journalctl -u servico -n 50

# 3. Verificar configuração
sudo servico -t  # nginx, apache
sudo servico configtest

# 4. Verificar permissões
ls -l /etc/servico/
ls -l /var/log/servico/

# 5. Verificar porta
sudo ss -tlnp | grep :80

# 6. Verificar SELinux/AppArmor
sudo ausearch -m avc -ts recent
sudo aa-status
```

### Boot Lento

```bash
# Analisar tempo de boot
systemd-analyze

# Serviços mais lentos
systemd-analyze blame

# Gráfico de boot
systemd-analyze plot > boot.svg

# Verificar serviços habilitados
systemctl list-unit-files --type=service --state=enabled
```

### Memória Alta

```bash
# 1. Ver uso
free -h

# 2. Processos por memória
ps aux --sort=-%mem | head

# 3. Limpar cache (seguro)
sudo sync
sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'

# 4. Verificar swap
swapon --show

# 5. Ver OOM killer logs
sudo dmesg | grep -i "out of memory"
sudo journalctl -k | grep -i "out of memory"
```

## Logs e Diagnóstico

### dmesg - Kernel Ring Buffer

```bash
# Ver mensagens do kernel
dmesg

# Últimas mensagens
dmesg | tail

# Buscar erros
dmesg | grep -i error

# Tempo legível
dmesg -T

# Seguir em tempo real
dmesg -w
```

### strace - Rastrear System Calls

```bash
# Rastrear comando
strace ls

# Rastrear processo em execução
sudo strace -p PID

# Salvar em arquivo
strace -o trace.txt comando

# Estatísticas
strace -c comando
```

### lsof - List Open Files

```bash
# Arquivos abertos por processo
sudo lsof -p PID

# Processos usando arquivo
sudo lsof /var/log/syslog

# Processos usando porta
sudo lsof -i :80

# Arquivos abertos por usuário
sudo lsof -u usuario

# Conexões de rede
sudo lsof -i
```

## Backup e Recuperação

### Backup do Sistema

```bash
# Backup completo (excluindo temporários)
sudo tar czf backup_sistema_$(date +%Y%m%d).tar.gz \
  --exclude=/proc \
  --exclude=/sys \
  --exclude=/dev \
  --exclude=/tmp \
  --exclude=/run \
  --exclude=/mnt \
  --exclude=/media \
  /

# Restaurar
sudo tar xzf backup_sistema.tar.gz -C /mnt/restauracao/
```

### Timeshift - Snapshots

```bash
# Instalar
sudo apt install timeshift

# Criar snapshot
sudo timeshift --create --comments "Antes da atualização"

# Listar snapshots
sudo timeshift --list

# Restaurar
sudo timeshift --restore
```

### rsnapshot - Backups Incrementais

```bash
# Instalar
sudo apt install rsnapshot

# Configurar
sudo vim /etc/rsnapshot.conf

# Executar backup
sudo rsnapshot daily
```

## Performance Tuning

### Swappiness

```bash
# Ver valor atual (0-100, padrão 60)
cat /proc/sys/vm/swappiness

# Definir temporário
sudo sysctl vm.swappiness=10

# Permanente
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
```

### I/O Scheduler

```bash
# Ver scheduler atual
cat /sys/block/sda/queue/scheduler

# Mudar (temporário)
echo deadline | sudo tee /sys/block/sda/queue/scheduler

# Permanente (udev rule)
sudo vim /etc/udev/rules.d/60-scheduler.rules
```

```
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="deadline"
```

### Limites de Recursos

```bash
# Ver limites
ulimit -a

# Aumentar arquivos abertos
ulimit -n 65536

# Permanente
sudo vim /etc/security/limits.conf
```

```
* soft nofile 65536
* hard nofile 65536
```

## Comandos de Referência Rápida

```bash
# Processos
ps aux
top
htop
kill PID

# Serviços
systemctl status servico
sudo systemctl restart servico

# Disco
df -h
du -sh /var
lsblk

# Performance
vmstat 2
iostat -x
free -h
uptime

# Logs
journalctl -u servico
dmesg | tail
tail -f /var/log/syslog

# Rede
ip addr show
ss -tlnp
ping google.com
```

## Recursos Adicionais

### Documentação

```bash
man comando
info comando
comando --help
```

### Comunidades

- [Stack Overflow](https://stackoverflow.com/questions/tagged/linux)
- [Unix & Linux Stack Exchange](https://unix.stackexchange.com/)
- [Reddit r/linuxadmin](https://www.reddit.com/r/linuxadmin/)
- [Linux Questions](https://www.linuxquestions.org/)

### Livros Recomendados

- "The Linux Command Line" - William Shotts
- "Linux System Administration" - Tom Adelstein
- "UNIX and Linux System Administration Handbook" - Evi Nemeth

### Certificações

- **LPIC-1**: Linux Professional Institute Certification
- **RHCSA**: Red Hat Certified System Administrator
- **Linux Foundation Certified System Administrator**

---

## Conclusão do Curso

Parabéns por completar o curso de Linux! Você agora tem conhecimento sobre:

✅ História e fundamentos do Linux
✅ Instalação e configuração
✅ Comandos de terminal e navegação
✅ Gerenciamento de arquivos e permissões
✅ Gerenciamento de pacotes
✅ Configuração de rede
✅ Scripts e automação
✅ Segurança
✅ Administração avançada e troubleshooting

### Próximos Passos

1. **Pratique**: Configure um servidor Linux (VM ou cloud)
2. **Automatize**: Crie scripts para tarefas rotineiras
3. **Contribua**: Participe de projetos open source
4. **Certifique-se**: Considere certificações profissionais
5. **Continue aprendendo**: Explore Docker, Kubernetes, Ansible

### Contato

Dúvidas ou sugestões? Entre em contato:
- **Blog**: [nerdseverino.com.br](https://www.nerdseverino.com.br)
- **LinkedIn**: [linkedin.com/in/fabriciomachado](https://www.linkedin.com/in/fabriciomachado)
- **GitHub**: [github.com/nerdseverino](https://github.com/nerdseverino)

---

**Capítulo anterior**: [8 - Segurança no Linux](https://www.nerdseverino.com.br/linux/8-seguran%C3%A7a-no-linux/)

**Voltar ao índice**: [Curso de Linux](https://www.nerdseverino.com.br/linux/%C3%ADndice/)
