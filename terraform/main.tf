terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
  }
}

variable "aws_region"         { default = "us-east-1" }
variable "cluster_name"       { default = "plateforme-paiement-eks" }
variable "cluster_version"    { default = "1.34" }
variable "node_instance_type" { default = "t3.medium" }
variable "node_desired"       { default = 2 }
variable "node_min"           { default = 1 }
variable "node_max"           { default = 3 }

provider "aws" { region = var.aws_region }

data "aws_vpc" "default" { default = true }

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

data "aws_iam_role" "lab_role" { name = "LabRole" }

locals {
  excluded_azs   = ["us-east-1e"]
  eks_subnet_ids = [
    for subnet in data.aws_subnet.details :
    subnet.id
    if !contains(local.excluded_azs, subnet.availability_zone)
  ]
}

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = data.aws_iam_role.lab_role.arn

  vpc_config {
    subnet_ids              = local.eks_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = false
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  timeouts { create = "25m"; update = "25m"; delete = "25m" }
}

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

  update_config { max_unavailable = 1 }

  lifecycle { ignore_changes = [scaling_config[0].desired_size] }
  depends_on = [aws_eks_cluster.main]
  timeouts { create = "25m"; update = "25m"; delete = "25m" }
}

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

resource "aws_eks_addon" "ebs_csi" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "aws-ebs-csi-driver"
  service_account_role_arn    = data.aws_iam_role.lab_role.arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_node_group.workers]
}

# StorageClass gp3 — default
resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner    = "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  parameters = {
    type      = "gp3"
    fsType    = "ext4"
    encrypted = "false"
  }
  depends_on = [aws_eks_addon.ebs_csi]
}

output "cluster_name"       { value = aws_eks_cluster.main.name }
output "cluster_endpoint"   { value = aws_eks_cluster.main.endpoint }
output "cluster_status"     { value = aws_eks_cluster.main.status }
output "eks_subnet_ids"     { value = local.eks_subnet_ids }
output "kubeconfig_command" { value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}" }
output "node_group_status"  { value = aws_eks_node_group.workers.status }
