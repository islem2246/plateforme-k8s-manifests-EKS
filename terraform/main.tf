# ============================================================
# Terraform — Cluster EKS pour Plateforme Électronique v12
# Compte AWS : 554813750145  |  Région : us-east-1
#
# ⚠️  AWS Academy : iam:CreateRole est interdit.
#     Utilise exclusivement LabRole (pré-existant).
#
# FIX v5 :
#   - OIDC provider pour EBS CSI Driver
#   - bootstrap_self_managed_addons = false (évite destroy)
# ============================================================

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# ============================================================
# Variables
# ============================================================

variable "aws_region"         { default = "us-east-1" }
variable "cluster_name"       { default = "plateforme-paiement-eks" }
variable "cluster_version"    { default = "1.34" }
variable "node_instance_type" { default = "t3.medium" }
variable "node_desired"       { default = 2 }
variable "node_min"           { default = 1 }
variable "node_max"           { default = 3 }

# ============================================================
# Provider
# ============================================================

provider "aws" {
  region = var.aws_region
}

# ============================================================
# Données existantes
# ============================================================

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "details" {
  for_each = toset(data.aws_subnets.all.ids)
  id       = each.value
}

data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# ============================================================
# Locals — filtrage des AZ non supportées
# ============================================================

locals {
  excluded_azs = ["us-east-1e"]

  eks_subnet_ids = [
    for subnet in data.aws_subnet.details :
    subnet.id
    if !contains(local.excluded_azs, subnet.availability_zone)
  ]
}

# ============================================================
# Cluster EKS
# ============================================================

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = data.aws_iam_role.lab_role.arn

  # Empêche Terraform de détruire/recréer le cluster lors d'un import
  bootstrap_self_managed_addons = false

  vpc_config {
    subnet_ids              = local.eks_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = false
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  tags = {
    Project   = "plateforme-electronique-paiement"
    ManagedBy = "terraform"
  }

  timeouts {
    create = "25m"
    update = "25m"
    delete = "25m"
  }
}

# ============================================================
# OIDC Provider — nécessaire pour EBS CSI Driver
# Sans OIDC, le CSI controller ne peut pas s'authentifier
# via AssumeRoleWithWebIdentity et crashe en boucle
# ============================================================

data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = {
    Project   = "plateforme-electronique-paiement"
    ManagedBy = "terraform"
  }
}

# ============================================================
# Node Group (workers)
# ============================================================

resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "workers"
  node_role_arn   = data.aws_iam_role.lab_role.arn
  subnet_ids      = local.eks_subnet_ids
  instance_types  = [var.node_instance_type]

  scaling_config {
    desired_size = var.node_desired
    min_size     = var.node_min
    max_size     = var.node_max
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Project   = "plateforme-electronique-paiement"
    ManagedBy = "terraform"
  }

  timeouts {
    create = "25m"
    update = "25m"
    delete = "25m"
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [aws_eks_cluster.main]
}

# ============================================================
# Addons EKS
# ============================================================

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_node_group.workers]
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_node_group.workers]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_node_group.workers]
}

# EBS CSI Driver — dépend de l'OIDC provider pour s'authentifier
resource "aws_eks_addon" "ebs_csi" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "aws-ebs-csi-driver"
  service_account_role_arn    = data.aws_iam_role.lab_role.arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [
    aws_eks_node_group.workers,
    aws_iam_openid_connect_provider.eks
  ]
}

# ============================================================
# Outputs
# ============================================================

output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_status" {
  value = aws_eks_cluster.main.status
}

output "eks_subnet_ids" {
  description = "Subnets utilisés par EKS (us-east-1e exclu)"
  value       = local.eks_subnet_ids
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}

output "node_group_status" {
  value = aws_eks_node_group.workers.status
}

output "oidc_provider_arn" {
  description = "ARN de l'OIDC provider (nécessaire pour EBS CSI)"
  value       = aws_iam_openid_connect_provider.eks.arn
}
