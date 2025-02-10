resource "aws_eks_cluster" "demo" {
  name     = "${var.environment}-eks"
  role_arn = aws_iam_role.demo.arn

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  vpc_config {
    subnet_ids = [
      var.private_subnet_1_id,
      var.private_subnet_2_id,
      var.private_subnet_3_id,
      var.public_subnet_1_id,
      var.public_subnet_2_id,
      var.public_subnet_3_id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.demo-AmazonEKSClusterPolicy]
}

resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.demo.name
  node_group_name = "private-nodes"
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = [
    var.private_subnet_1_id,
    var.private_subnet_2_id,
    var.private_subnet_3_id
  ]

  capacity_type  = "SPOT"
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    node = "${var.environment}-kubenode"
  }

  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_eks_access_entry" "example" {
  cluster_name      = aws_eks_cluster.demo.name
  principal_arn     = "arn:aws:iam::864899873372:root"
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "ss" {
  cluster_name  = aws_eks_cluster.demo.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::864899873372:root"

  access_scope {
    type       = "cluster"
  }
}

resource "aws_eks_access_policy_association" "s5" {
  cluster_name  = aws_eks_cluster.demo.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = "arn:aws:iam::864899873372:root"

  access_scope {
    type       = "cluster"
  }
}