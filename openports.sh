#!/bin/bash
# Récupérer le SG ID automatiquement
SG_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:eks:cluster-name,Values=plateforme-paiement-eks" \
  --query 'Reservations[].Instances[].SecurityGroups[].GroupId' \
  --output text --region us-east-1 | awk '{print $1}')

echo "Security Group : $SG_ID"

# Ouvrir le port 30180 (Frontend)
aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol tcp --port 30180 --cidr 0.0.0.0/0 \
  --region us-east-1 && echo "✅ Port 30180 ouvert"

# Ouvrir le port 30881 (Keycloak)
aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol tcp --port 30881 --cidr 0.0.0.0/0 \
  --region us-east-1 && echo "✅ Port 30881 ouvert"
