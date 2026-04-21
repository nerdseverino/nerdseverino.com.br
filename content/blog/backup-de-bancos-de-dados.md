---
title: "Backup de Bancos de Dados: Do Dump ao Point-in-Time Recovery"
date: 2026-05-27T08:00:00-03:00
description: |
  "Temos backup?" é a pergunta que ninguém quer ouvir durante um incidente.

  Guia completo de backup para quem opera bancos em produção:

  🐬 MySQL/MariaDB: mysqldump, xtrabackup, binlog
  🐘 PostgreSQL: pg_dump, pg_basebackup, WAL archiving
  🍃 MongoDB: mongodump, oplog
  ☁️ AWS: RDS snapshots, PITR, AWS Backup

  Inclui estratégia 3-2-1, automação com cron e validação de restore.

  Quando foi a última vez que você testou um restore?

  🔗 https://nerdseverino.com.br/blog/backup-de-bancos-de-dados/

  #Backup #Database #MySQL #PostgreSQL #MongoDB #AWS #SRE
coverImage: /images/uploads/cover-backup-db.png
categories:
  - SRE
tags:
  - serie-sre-na-pratica
  - backup
  - database
  - mysql
  - postgresql
  - mongodb
  - aws
keywords:
  - backup banco de dados
  - mysqldump
  - pg_dump
  - point in time recovery
  - aws backup
coverImage: /images/uploads/cover-backup-db.png
autoThumbnailImage: false
coverImage: /images/uploads/cover-backup-db.png
thumbnailImagePosition: top
---

Backup que não é testado não é backup. É esperança. Este guia cobre desde o dump básico até point-in-time recovery na AWS, com foco em operação real.

<!--more-->

## Estratégia 3-2-1

Antes de qualquer ferramenta:

- **3** cópias dos dados
- **2** tipos de mídia diferentes
- **1** cópia offsite (outra região, outra conta, outro provider)

## MySQL / MariaDB

### mysqldump (lógico)

O mais simples. Gera SQL que recria o banco:

```bash
# Backup completo de todos os bancos
mysqldump -u root -p --all-databases --single-transaction \
  --routines --triggers > backup_full_$(date +%Y%m%d).sql

# Banco específico
mysqldump -u root -p --single-transaction mydb > mydb_$(date +%Y%m%d).sql

# Comprimido
mysqldump -u root -p --single-transaction mydb | gzip > mydb_$(date +%Y%m%d).sql.gz

# Restore
mysql -u root -p mydb < backup.sql
# Ou comprimido
gunzip < backup.sql.gz | mysql -u root -p mydb
```

Flags importantes:

| Flag | Função |
|------|--------|
| `--single-transaction` | Backup consistente sem lock (InnoDB) |
| `--routines` | Inclui stored procedures e functions |
| `--triggers` | Inclui triggers |
| `--events` | Inclui eventos agendados |
| `--master-data=2` | Inclui posição do binlog (para réplicas) |

### Percona XtraBackup (físico)

Para bancos grandes onde mysqldump é lento demais:

```bash
# Backup completo (hot, sem lock)
xtrabackup --backup --target-dir=/backup/full

# Preparar para restore
xtrabackup --prepare --target-dir=/backup/full

# Restore (MySQL precisa estar parado)
systemctl stop mysql
xtrabackup --copy-back --target-dir=/backup/full
chown -R mysql:mysql /var/lib/mysql
systemctl start mysql
```

### Binlog (point-in-time)

Com binlog habilitado, você pode restaurar até um momento específico:

```bash
# Verificar se binlog está ativo
SHOW VARIABLES LIKE 'log_bin';

# Listar binlogs
SHOW BINARY LOGS;

# Restore até timestamp específico
mysqlbinlog --stop-datetime="2026-05-27 14:30:00" binlog.000042 | mysql -u root -p
```

## PostgreSQL

### pg_dump (lógico)

```bash
# Backup de um banco
pg_dump -U postgres -Fc mydb > mydb_$(date +%Y%m%d).dump

# Backup de todos os bancos
pg_dumpall -U postgres > all_databases_$(date +%Y%m%d).sql

# Restore (formato custom)
pg_restore -U postgres -d mydb mydb.dump

# Restore (SQL puro)
psql -U postgres -d mydb < backup.sql
```

Formatos de saída:

| Formato | Flag | Vantagem |
|---------|------|----------|
| Custom (-Fc) | Comprimido, restore seletivo | Recomendado |
| Directory (-Fd) | Paralelo, múltiplos arquivos | Bancos grandes |
| Plain (-Fp) | SQL legível | Debug, portabilidade |

### pg_basebackup (físico)

```bash
# Backup físico completo
pg_basebackup -U replicator -D /backup/base -Ft -z -P

# Com WAL incluído
pg_basebackup -U replicator -D /backup/base -Ft -z -P -X stream
```

### WAL Archiving (point-in-time)

Configure no `postgresql.conf`:

```ini
wal_level = replica
archive_mode = on
archive_command = 'cp %p /backup/wal/%f'
```

Restore até um ponto específico:

```ini
# recovery.conf (ou postgresql.conf no PG12+)
restore_command = 'cp /backup/wal/%f %p'
recovery_target_time = '2026-05-27 14:30:00'
```

## MongoDB

### mongodump

```bash
# Backup completo
mongodump --uri="mongodb://localhost:27017" --out=/backup/$(date +%Y%m%d)

# Banco específico
mongodump --db mydb --out=/backup/$(date +%Y%m%d)

# Comprimido
mongodump --archive=/backup/mongo_$(date +%Y%m%d).gz --gzip

# Restore
mongorestore --uri="mongodb://localhost:27017" /backup/20260527/

# Restore comprimido
mongorestore --archive=/backup/mongo_20260527.gz --gzip
```

### Oplog (point-in-time)

```bash
# Backup com oplog (para replica sets)
mongodump --oplog --out=/backup/$(date +%Y%m%d)

# Restore com replay do oplog
mongorestore --oplogReplay /backup/20260527/
```

## AWS: RDS e Aurora

### Snapshots automáticos

```bash
# Listar snapshots
aws rds describe-db-snapshots \
  --db-instance-identifier mydb-prod \
  --query 'DBSnapshots[].{ID:DBSnapshotIdentifier,Time:SnapshotCreateTime,Status:Status}'

# Criar snapshot manual
aws rds create-db-snapshot \
  --db-instance-identifier mydb-prod \
  --db-snapshot-identifier mydb-prod-pre-deploy-$(date +%Y%m%d)

# Restaurar (cria nova instância)
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier mydb-restored \
  --db-snapshot-identifier mydb-prod-pre-deploy-20260527
```

### Point-in-Time Recovery (PITR)

RDS mantém backups contínuos. Você pode restaurar para qualquer segundo dentro da janela de retenção:

```bash
# Restaurar para momento específico
aws rds restore-db-instance-to-point-in-time \
  --source-db-instance-identifier mydb-prod \
  --target-db-instance-identifier mydb-pitr \
  --restore-time "2026-05-27T14:30:00Z"

# Restaurar para o último momento possível
aws rds restore-db-instance-to-point-in-time \
  --source-db-instance-identifier mydb-prod \
  --target-db-instance-identifier mydb-pitr \
  --use-latest-restorable-time
```

### AWS Backup

Centraliza backup de múltiplos serviços (RDS, DynamoDB, EFS, EBS, S3):

```bash
# Criar plano de backup
aws backup create-backup-plan --backup-plan '{
  "BackupPlanName": "daily-7d-retention",
  "Rules": [{
    "RuleName": "daily",
    "ScheduleExpression": "cron(0 3 * * ? *)",
    "TargetBackupVaultName": "Default",
    "Lifecycle": {"DeleteAfterDays": 7}
  }]
}'
```

## Automação com Cron

```bash
#!/bin/bash
# backup_databases.sh
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup/$DATE"
mkdir -p "$BACKUP_DIR"

# MySQL
mysqldump -u backup_user -p"$MYSQL_PASS" --all-databases \
  --single-transaction | gzip > "$BACKUP_DIR/mysql_all.sql.gz"

# PostgreSQL
pg_dumpall -U postgres | gzip > "$BACKUP_DIR/postgres_all.sql.gz"

# Manter últimos 7 dias
find /backup -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;

# Sync para S3 (offsite)
aws s3 sync /backup/ s3://meu-bucket-backup/databases/ --delete
```

```bash
# Crontab: todo dia às 3h
0 3 * * * /scripts/backup_databases.sh >> /var/log/backup.log 2>&1
```

## Validação: teste o restore

Backup sem teste de restore é esperança, não estratégia:

```bash
#!/bin/bash
# test_restore.sh - rodar mensalmente
# 1. Pegar último backup
# 2. Restaurar em instância temporária
# 3. Rodar queries de validação
# 4. Destruir instância temporária
# 5. Notificar resultado
```

## Checklist

- [ ] Backup automático diário
- [ ] Retenção definida (7d local, 30d offsite)
- [ ] Cópia offsite (S3 outra região ou outra conta)
- [ ] PITR habilitado (binlog/WAL/oplog)
- [ ] Teste de restore mensal
- [ ] Monitoramento de falha de backup (alarme)
- [ ] Documentação do procedimento de restore

---

*O melhor momento para configurar backup é antes de precisar. O segundo melhor é agora. E lembre: backup que não é testado não é backup.*
