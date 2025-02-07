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

data "aws_eks_cluster" "example" {
  name = aws_eks_cluster.demo.name
}

resource "aws_launch_template" "eks_nodes" {
  name_prefix   = "eks-node-template"
  image_id      = "ami-0cb91c7de36eed2cb" # EKS-optimized AMI
  instance_type = "t3.medium"

  network_interfaces {
    # associate_public_ip_address = true
    associate_public_ip_address = aws_eks_cluster.demo.
    security_groups             = [aws_security_group.eks_nodes.id]
  }

  user_data = base64encode(templatefile(
    path("./linux_user_data.tpl"),
    {
      cluster_name        = aws_eks_cluster.demo.name
      cluster_endpoint    = aws_eks_cluster.demo.endpoint
      cluster_auth_base64 = data.aws_eks_cluster.example.certificate_authority[0].data

      cluster_service_cidr = data.aws_eks_cluster.example.kubernetes_network_config[0].service_ipv4_cidr
      cluster_ip_family    = data.aws_eks_cluster.example.kubernetes_network_config[0].ip_family
    }
  ))
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