locals {
  cluster_name          = var.project_name
  cluster_role_name     = "${var.project_name}-cluster-role"
  cluster_role_policy_1 = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
