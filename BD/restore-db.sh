#!/bin/bash
# ============================================================
# restore-db.sh — Restauration des bases PostgreSQL
# v2 : Force la déconnexion des sessions avant DROP
# ============================================================
BACKUP_DIR=$1
NAMESPACE="plateforme-electronique"
POSTGRES_POD=$(kubectl get pod -n $NAMESPACE -l app=postgres -o jsonpath='{.items[0].metadata.name}')
POSTGRES_USER="postgres"

if [ -z "$BACKUP_DIR" ]; then
  echo "Usage: ./restore-db.sh ./backups/YYYYMMDD_HHMMSS"
  echo ""
  echo "Available backups:"
  ls -lt ./backups/ 2>/dev/null || echo "  Aucun backup trouvé"
  exit 1
fi

echo "=== RESTORE FROM: $BACKUP_DIR ==="
echo "Pod: $POSTGRES_POD"
echo ""
echo "⚠️  ATTENTION : Cette opération va :"
echo "    1. Couper toutes les connexions aux bases"
echo "    2. Supprimer et recréer chaque base"
echo "    3. Restaurer les données depuis le backup"
echo ""
read -p "⚠️  Confirmer la restauration ? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Annulé."
  exit 0
fi

# Optionnel : scaler les services à 0 pour éviter les reconnexions pendant la restore
echo ""
echo "=== Arrêt temporaire des microservices ==="
DEPLOYMENTS="invoice-service payment-service subscription-service notification-service user-auth-service api-gateway"
for DEP in $DEPLOYMENTS; do
  kubectl scale deployment/$DEP -n $NAMESPACE --replicas=0 2>/dev/null && \
    echo "  ⏸  $DEP → 0 replicas" || echo "  ⚠️  $DEP non trouvé"
done

echo "  ⏳ Attente de l'arrêt des pods (15s)..."
sleep 15

echo ""
echo "=== Restauration des bases ==="
ERRORS=0
for DB in invoice_db payment_db subscription_db notification_db user_auth_db; do
  if [ -f "$BACKUP_DIR/$DB.sql" ]; then
    echo ""
    echo "--- Restoring $DB ---"

    # 1. Forcer la déconnexion de TOUTES les sessions sur cette base
    echo "  [1/3] Déconnexion des sessions actives..."
    kubectl exec -n $NAMESPACE $POSTGRES_POD -- \
      psql -U $POSTGRES_USER -c \
      "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DB' AND pid <> pg_backend_pid();" \
      2>/dev/null

    # 2. Drop + Recreate
    echo "  [2/3] DROP + CREATE $DB..."
    kubectl exec -n $NAMESPACE $POSTGRES_POD -- \
      psql -U $POSTGRES_USER -c "DROP DATABASE IF EXISTS $DB;"
    
    if [ $? -ne 0 ]; then
      echo "  ❌ Échec DROP $DB — tentative avec FORCE (PostgreSQL 13+)..."
      kubectl exec -n $NAMESPACE $POSTGRES_POD -- \
        psql -U $POSTGRES_USER -c "DROP DATABASE IF EXISTS $DB WITH (FORCE);"
    fi

    kubectl exec -n $NAMESPACE $POSTGRES_POD -- \
      psql -U $POSTGRES_USER -c "CREATE DATABASE $DB OWNER $POSTGRES_USER;"

    if [ $? -ne 0 ]; then
      echo "  ❌ Échec CREATE $DB — skip"
      ERRORS=$((ERRORS+1))
      continue
    fi

    # 3. Restaurer le dump
    echo "  [3/3] Import du dump..."
    cat "$BACKUP_DIR/$DB.sql" | kubectl exec -i -n $NAMESPACE $POSTGRES_POD -- \
      psql -U $POSTGRES_USER -d $DB --single-transaction 2>&1 | \
      grep -E "^(ERROR|FATAL)" || true

    echo "  ✅ $DB restauré"
  else
    echo "  ⚠️  $DB.sql non trouvé dans $BACKUP_DIR, ignoré"
  fi
done

# Redémarrer les services
echo ""
echo "=== Redémarrage des microservices ==="
kubectl scale deployment/invoice-service -n $NAMESPACE --replicas=1
kubectl scale deployment/payment-service -n $NAMESPACE --replicas=2
kubectl scale deployment/subscription-service -n $NAMESPACE --replicas=1
kubectl scale deployment/notification-service -n $NAMESPACE --replicas=1
kubectl scale deployment/user-auth-service -n $NAMESPACE --replicas=1
kubectl scale deployment/api-gateway -n $NAMESPACE --replicas=2
echo "  ✅ Tous les services relancés"

echo ""
echo "=== RESTORE COMPLETE ==="
if [ $ERRORS -gt 0 ]; then
  echo "⚠️  $ERRORS erreur(s) rencontrée(s) — vérifiez les logs ci-dessus"
else
  echo "✅ Aucune erreur"
fi
echo ""
echo "Vérification : kubectl get pods -n $NAMESPACE -w"
