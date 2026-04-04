#!/bin/bash
# Script de sauvegarde complète

BACKUP_DIR=~/backups/$(date +%Y%m%d_%H%M%S)
POD="postgres-8d89d6848-5qlbx"
NS="plateforme-electronique"

mkdir -p $BACKUP_DIR

for DB in user_auth_db payment_db invoice_db subscription_db notification_db; do
    echo "Sauvegarde de $DB..."
    kubectl exec -n $NS $POD -- pg_dump -U postgres $DB > $BACKUP_DIR/$DB.sql
done

echo "Sauvegarde complète dans: $BACKUP_DIR"
ls -la $BACKUP_DIR
