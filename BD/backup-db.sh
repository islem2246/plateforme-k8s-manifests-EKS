#!/bin/bash
# backup-db.sh

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups/$TIMESTAMP"
POSTGRES_POD=$(kubectl get pod -n plateforme-electronique -l app=postgres -o jsonpath='{.items[0].metadata.name}')
POSTGRES_USER="postgres"

mkdir -p $BACKUP_DIR

echo "=== BACKUP STARTED : $TIMESTAMP ==="
echo "Pod: $POSTGRES_POD"

for DB in invoice_db payment_db subscription_db notification_db user_auth_db; do
  echo "Backing up $DB..."
  kubectl exec -n plateforme-electronique $POSTGRES_POD -- \
    pg_dump -U $POSTGRES_USER $DB > $BACKUP_DIR/$DB.sql
  echo "  ✅ $DB → $BACKUP_DIR/$DB.sql"
done

echo ""
echo "=== BACKUP COMPLETE ==="
echo "Location: $BACKUP_DIR"
ls -lh $BACKUP_DIR
