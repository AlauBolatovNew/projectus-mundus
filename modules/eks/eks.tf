resource "aws_eks_cluster" "demo" {
  name     = "${var.environment}-eks"
  role_arn = aws_iam_role.demo.arn
  version  = var.eks_version

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

resource "aws_launch_template" "eks_nodes" {
  name_prefix   = "eks-node-template"
  image_id      = "ami-0cb91c7de36eed2cb" # EKS-optimized AMI
  instance_type = "t3.medium"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.eks_nodes.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eks-node"
    }
  }
}

resource "aws_autoscaling_group" "eks_nodes" {
  name = "eks-node-group"
  vpc_zone_identifier = [
    var.private_subnet_1_id,
    var.private_subnet_2_id,
    var.private_subnet_3_id,
    var.public_subnet_1_id,
    var.public_subnet_2_id,
    var.public_subnet_3_id
  ]
  min_size         = 1
  max_size         = 5
  desired_capacity = 3

  mixed_instances_policy {
    instances_distribution {
      on_demand_percentage_above_base_capacity = 20 # 20% On-Demand, 80% Spot
      spot_allocation_strategy                 = "lowest-price"
      on_demand_base_capacity                  = 0
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.eks_nodes.id
      }

      override { instance_type = "t3.medium" }
      override { instance_type = "t3.large" }
      override { instance_type = "m5.large" }
    }
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.environment}-eks"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.environment}-eks"
    value               = "owned"
    propagate_at_launch = true
  }
}


# resource "aws_eks_node_group" "private-nodes" {
#   cluster_name    = aws_eks_cluster.demo.name
#   node_group_name = "private-nodes"
#   node_role_arn   = aws_iam_role.nodes.arn

#   subnet_ids = [
#     var.private_subnet_1_id,
#     var.private_subnet_2_id,
#     var.private_subnet_3_id
#   ]

#   capacity_type  = "SPOT"
#   instance_types = ["t3.medium"]

#   scaling_config {
#     desired_size = 3
#     max_size     = 5
#     min_size     = 1
#   }

#   update_config {
#     max_unavailable = 1
#   }

#   labels = {
#     node = "${var.environment}-kubenode"
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
#   ]
# }
