# Plateforme Électronique de Paiement — v12/v13

Pipeline CI/CD complet pour le déploiement d'une plateforme de paiement basée sur des microservices Spring Boot, orchestrée sur **AWS EKS** via **Terraform** + **GitHub Actions**, avec support **ArgoCD GitOps**.

---

## Table des matières

- [Architecture](#architecture)
- [Stack technique](#stack-technique)
- [Structure du dépôt](#structure-du-dépôt)
- [Prérequis](#prérequis)
- [Configuration des secrets GitHub](#configuration-des-secrets-github)
- [Pipelines GitHub Actions](#pipelines-github-actions)
- [Déploiement pas à pas](#déploiement-pas-à-pas)
- [Accès à la plateforme](#accès-à-la-plateforme)
- [Sauvegarde et restauration](#sauvegarde-et-restauration)
- [Gestion des credentials AWS Academy](#gestion-des-credentials-aws-academy)
- [Troubleshooting](#troubleshooting)

---

## Architecture

```
GitHub (master)
      │
      ├── push ──────────────────────────────────────────────────────┐
      │                                                               │
      ▼                                                               ▼
terraform.yml                                                   deploy.yml
(manuel uniquement)                                    (push auto + manuel)
      │                                                               │
      ▼                                                               ├── mode: kubectl  → kubectl apply (8 étapes)
AWS EKS Cluster                                                       ├── mode: argocd   → Install ArgoCD + GitOps
  ├── Node Group (t3.medium × 2)                                      └── mode: sync     → Resync ArgoCD
  ├── Addon: vpc-cni
  ├── Addon: coredns
  ├── Addon: kube-proxy
  └── Addon: aws-ebs-csi-driver
        │
        └── Namespace: plateforme-electronique
              ├── PostgreSQL  (PVC gp2-csi)
              ├── Redis       (PVC gp2-csi)
              ├── Keycloak    (Auth/SSO)
              ├── API Gateway (LoadBalancer)
              ├── Frontend    (NodePort 30180)
              ├── Microservices métier
              │     ├── payment-service
              │     ├── invoice-service
              │     ├── subscription-service
              │     ├── notification-service
              │     ├── user-auth-service
              │     └── signature-service
              └── Jobs
                    ├── keycloak-realm-import
                    └── seed-users
```

---

## Stack technique

| Composant | Technologie |
|-----------|-------------|
| Microservices | Spring Boot |
| Base de données | PostgreSQL |
| Cache | Redis |
| Authentification | Keycloak |
| Conteneurisation | Docker |
| Orchestration | Kubernetes (AWS EKS 1.32) |
| Infrastructure as Code | Terraform 1.7+ |
| CI/CD | GitHub Actions |
| GitOps | ArgoCD |
| Registry | Docker Hub (yassmineg) |
| Cloud | AWS (us-east-1) |
| Environnement local | Rancher Desktop / k3d (WSL2) |

---

## Structure du dépôt

```
<<<<<<< HEAD
k8s-manifests/
├── 00-namespace/          # Namespace dédié
├── 01-secrets-configmaps/ # Secrets + ConfigMaps (DB, Redis, SMTP, routes gateway)
├── 02-infrastructure/     # PostgreSQL, Redis, Keycloak
├── 03-gateway/            # API Gateway (routes DNS K8s, StripPrefix=0)
├── 04-services/           # 6 microservices métier
├── 05-frontend/           # React SPA + Nginx proxy config
├── 06-ingress/            # Ingress Traefik + NodePort + LoadBalancer
├── 07-keycloak-realm/     # Import realm Keycloak (Job)
├── 08-post-deploy/        # Seed users (Job) — enregistrement via API
├── deploy.sh              # Script de déploiement (8 étapes)
├── destroy.sh             # Script de suppression
└── README.md
=======
plateforme-k8s-manifests/
│
├── .github/
│   └── workflows/
│       ├── terraform.yml       # Créer / détruire le cluster EKS (manuel)
│       └── deploy.yml          # Déployer la plateforme (kubectl / argocd / sync)
│
├── terraform/
│   └── main.tf                 # Cluster EKS + Node Group + Addons (LabRole)
│
├── 00-namespace/               # Namespace plateforme-electronique
├── 01-secrets-configmaps/      # Secrets et ConfigMaps
├── 02-infrastructure/          # PostgreSQL, Redis, Keycloak, StorageClass gp2-csi
├── 03-gateway/                 # API Gateway (ClusterIP + LoadBalancer)
├── 04-services/                # Microservices métier
├── 05-frontend/                # Frontend Nginx
├── 06-ingress/                 # Ingress rules
├── 07-keycloak-realm/          # Job import realm Keycloak
├── 08-post-deploy/             # Job seed-users
│
├── BD/
│   ├── restore-db.sh           # Script de restauration PostgreSQL
│   └── backups/                # Dumps SQL par date
│       ├── 20260305_172402/
│       └── 20260314_162853/
│
└── deploy.sh                   # Script de déploiement local (k3d / Rancher)
>>>>>>> 04493f8 (docs: README complet — architecture EKS + pipelines + troubleshooting)
```

---

## Prérequis

### Outils locaux (WSL2)

```bash
# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# gh CLI (gestion des secrets GitHub)
sudo apt install gh -y
gh auth login
```

### Compte AWS Academy

- Compte : `731603087226`
- Région : `us-east-1`
- Rôle IAM disponible : `LabRole` (pré-existant, utilisé pour EKS)
- ⚠️ `iam:CreateRole` interdit → Terraform utilise uniquement `LabRole`

---

## Configuration des secrets GitHub

```
GitHub → Settings → Secrets and variables → Actions → New repository secret
```

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | Depuis AWS Academy → AWS Details → Show |
| `AWS_SECRET_ACCESS_KEY` | Depuis AWS Academy → AWS Details → Show |
| `AWS_SESSION_TOKEN` | Token complet (commence par `IQoJ`, se termine par `=`) |

### Mise à jour automatique depuis WSL (à chaque session Lab)

```bash
# Après avoir collé les credentials dans ~/.aws/credentials
REPO="ngrassa/plateforme-k8s-manifests"

gh secret set AWS_ACCESS_KEY_ID \
  --body "$(grep aws_access_key_id ~/.aws/credentials | cut -d= -f2-)" \
  --repo $REPO

gh secret set AWS_SECRET_ACCESS_KEY \
  --body "$(grep aws_secret_access_key ~/.aws/credentials | cut -d= -f2-)" \
  --repo $REPO

gh secret set AWS_SESSION_TOKEN \
  --body "$(grep aws_session_token ~/.aws/credentials | cut -d= -f2-)" \
  --repo $REPO
```

> ⚠️ Les credentials STS AWS Academy expirent toutes les **~1 heure**. Répéter cette opération à chaque nouvelle session Lab.

---

## Pipelines GitHub Actions

### `terraform.yml` — Gestion du cluster EKS

**Déclenchement : manuel uniquement**

```
GitHub → Actions → Terraform — EKS Cluster → Run workflow
```

| Action | Effet |
|--------|-------|
| `apply` | Crée le cluster EKS (ignoré si déjà ACTIVE) |
| `destroy` | Nettoyage K8s propre (LB, PVCs, namespace) puis `terraform destroy` |

> Le destroy suit 5 étapes ordonnées pour éviter les ressources AWS orphelines :
> 1. Configurer kubectl
> 2. Supprimer les LoadBalancers
> 3. Supprimer les PVCs + volumes EBS
> 4. Supprimer le namespace
> 5. `terraform destroy`

---

### `deploy.yml` — Déploiement de la plateforme

**Déclenchement : push sur `master` (mode kubectl auto) + manuel**

```
GitHub → Actions → Deploy Plateforme v12 → Run workflow
```

| Mode | Quand l'utiliser |
|------|-----------------|
| `kubectl` | Déploiement rapide — miroir exact de `deploy.sh` v12 — **mode par défaut sur push** |
| `argocd` | Première installation ArgoCD + création de l'app GitOps |
| `sync` | ArgoCD déjà installé — resynchroniser après un push |

**Chaque déploiement inclut automatiquement :**
- Vérification que le cluster EKS est ACTIVE
- Installation/vérification de l'addon EBS CSI Driver
- Création du StorageClass `gp2-csi` (provisioner `ebs.csi.aws.com`)

---

## Déploiement pas à pas

### 1. Créer le cluster EKS

```
GitHub → Actions → Terraform — EKS Cluster
→ Run workflow → action: apply → Run workflow
```

Durée : ~15 min. Vérifier depuis WSL :

```bash
aws eks describe-cluster \
  --name plateforme-paiement-eks \
  --region us-east-1 \
  --query 'cluster.status'
# → "ACTIVE"
```

<<<<<<< HEAD
## Suppression
=======
### 2. Configurer kubectl local

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name plateforme-paiement-eks

kubectl get nodes
```

### 3. Ouvrir les ports NodePort (Security Group)

```bash
chmod +x ~/openports.sh && ~/openports.sh
```

> Ce script détecte automatiquement le Security Group des nodes EC2 et ouvre les ports 30180 (Frontend) et 30881 (Keycloak).

### 4. Déployer la plateforme

**Via push :**
```bash
git add . && git commit -m "deploy" && git push
```

**Via GitHub Actions (manuel) :**
```
GitHub → Actions → Deploy Plateforme v12
→ Run workflow → mode: kubectl → Run workflow
```

### 5. Vérifier les pods
>>>>>>> 04493f8 (docs: README complet — architecture EKS + pipelines + troubleshooting)

```bash
kubectl get pods -n plateforme-electronique -w
```

Tous les pods doivent passer à `Running` dans cet ordre :
1. `postgres` et `redis` (~2 min, dépend du provisionnement EBS)
2. `keycloak` (~3 min)
3. Tous les microservices (Init → Running)

---

## Accès à la plateforme

### Obtenir les IPs des nodes

```bash
<<<<<<< HEAD
cd k8s-manifests
git init
git add .
git commit -m "feat: K8s manifests v12 - StripPrefix=0, seed-users job"
git remote add origin https://github.com/yassmineg/plateforme-k8s-manifests.git
git push -u origin main
=======
kubectl get nodes -o wide
# Colonne EXTERNAL-IP → ex: 52.71.231.182 et 34.204.178.152
>>>>>>> 04493f8 (docs: README complet — architecture EKS + pipelines + troubleshooting)
```

### URLs d'accès

| Service | URL |
|---------|-----|
| Frontend | `http://<NODE_IP>:30180` |
| Keycloak Admin | `http://<NODE_IP>:30881` |
| API Gateway (LB) | `http://aba2a8a47229448229aee9521ce642d2-1039227130.us-east-1.elb.amazonaws.com:8080` |

### Conversion IP → DNS AWS

```
52.71.231.182  →  http://ec2-52-71-231-182.compute-1.amazonaws.com:30180
34.204.178.152 →  http://ec2-34-204-178-152.compute-1.amazonaws.com:30180
```

### Utilisateurs de test

| Utilisateur | Mot de passe | Email |
|-------------|-------------|-------|
| `admin` | `admin123` | admin@plateforme.local |
| `user1` | `user123` | user1@plateforme.local |
| `merchant1` | `merchant123` | merchant1@plateforme.local |

---

## Sauvegarde et restauration

### Restaurer depuis un backup

```bash
cd ~/yesmine/k8s-manifests-v13/k8s-manifests/BD

# Vérifier que kubectl pointe sur EKS
kubectl config current-context

# Lister les backups disponibles
ls backups/

# Restaurer le backup le plus récent
./restore-db.sh ./backups/20260314_162853
```

> ⚠️ Le pod `postgres` doit être en status `Running` avant de lancer le restore.

### Backups disponibles

| Date | Bases incluses |
|------|---------------|
| `20260314_162853` | invoice_db, payment_db, subscription_db, notification_db, user_auth_db |
| `20260305_172402` | invoice_db, payment_db, subscription_db, notification_db, user_auth_db |

---

## Gestion des credentials AWS Academy

Les credentials STS (`ASIA...`) expirent toutes les **~1 heure**.

### Procédure de renouvellement

```bash
# 1. AWS Academy → Start Lab → AWS Details → Show → copier le bloc

# 2. Mettre à jour ~/.aws/credentials
nano ~/.aws/credentials

# 3. Mettre à jour les secrets GitHub automatiquement
REPO="ngrassa/plateforme-k8s-manifests"
gh secret set AWS_ACCESS_KEY_ID \
  --body "$(grep aws_access_key_id ~/.aws/credentials | cut -d= -f2-)" --repo $REPO
gh secret set AWS_SECRET_ACCESS_KEY \
  --body "$(grep aws_secret_access_key ~/.aws/credentials | cut -d= -f2-)" --repo $REPO
gh secret set AWS_SESSION_TOKEN \
  --body "$(grep aws_session_token ~/.aws/credentials | cut -d= -f2-)" --repo $REPO

# 4. Reconfigurer kubectl
aws eks update-kubeconfig --region us-east-1 --name plateforme-paiement-eks
```

### Basculer entre clusters (local ↔ EKS)

```bash
# Voir tous les contextes
kubectl config get-contexts

# EKS
kubectl config use-context arn:aws:eks:us-east-1:731603087226:cluster/plateforme-paiement-eks

# Local (Rancher Desktop)
kubectl config use-context rancher-desktop
```

---

## Troubleshooting

### postgres / redis en `Pending`

```bash
# Vérifier les PVCs
kubectl get pvc -n plateforme-electronique

# Vérifier l'addon EBS
aws eks describe-addon \
  --cluster-name plateforme-paiement-eks \
  --addon-name aws-ebs-csi-driver \
  --region us-east-1 \
  --query 'addon.status'
```

Si `CREATE_FAILED` :
```bash
aws eks delete-addon --cluster-name plateforme-paiement-eks \
  --addon-name aws-ebs-csi-driver --region us-east-1
sleep 10
aws eks create-addon --cluster-name plateforme-paiement-eks \
  --addon-name aws-ebs-csi-driver --region us-east-1
```

### StorageClass gp2-csi manquant

```bash
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp2-csi
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Retain
parameters:
  type: gp2
EOF
kubectl patch storageclass gp2 \
  -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```

### Erreur `Could not load credentials`

Credentials GitHub expirés → relancer le script de renouvellement ci-dessus.

### Erreur `Invalid character in header content [x-amz-security-token]`

Le `AWS_SESSION_TOKEN` contient un caractère parasite (saut de ligne).
Utiliser le script `gh secret set` pour éviter toute manipulation manuelle.

### Terraform : `Cluster already exists`

L'état Terraform est vide (pas de backend S3). Terraform ne connaît pas le cluster existant.
→ Utiliser uniquement `deploy.yml` pour les déploiements. `terraform.yml` sert uniquement à créer/détruire depuis zéro.

### Pods en `CrashLoopBackOff`

```bash
# Voir les logs
kubectl logs -n plateforme-electronique <pod-name> --previous

# Voir les events
kubectl get events -n plateforme-electronique \
  --sort-by='.lastTimestamp' | tail -20
```

### Ports NodePort inaccessibles

```bash
# Réouvrir les ports Security Group
~/openports.sh
```
```bash
# Accès au projet (plateforme electronique)
 kubectl get nodes -o wide
 http://<EXTERNAL-IP>:30180
```
#OU 

```bash
# Patch avec Loadbalaner

# Frontend
kubectl patch svc frontend-nodeport -n plateforme-electronique \
  -p '{"spec": {"type": "LoadBalancer"}}'

# Keycloak
kubectl patch svc keycloak-nodeport -n plateforme-electronique \
  -p '{"spec": {"type": "LoadBalancer"}}'


kubectl get svc -n plateforme-electronique | grep LoadBalancer
```
# (ex:Frontend) : http://ae1a2765e215d4ebb852a5d982ae5868-1363864390.us-east-1.elb.amazonaws.com
---

## Auteur
Projet réalisé supervisé avec par les étudiantes **Yesmine et Islem** 
