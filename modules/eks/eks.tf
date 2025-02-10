resource "aws_eks_cluster" "demo" {
  name     = "centos-eks"
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
    # security_group_ids = [var.security_group_id]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  kubernetes_network_config {
    service_ipv4_cidr = "172.20.0.0/16"
  }

  depends_on = [aws_iam_role_policy_attachment.demo-AmazonEKSClusterPolicy]
}

# Define the Launch Template for Worker Nodes
resource "aws_launch_template" "eks_launch_template" {
  name_prefix   = "eks-node-"
  instance_type = "t3.medium"
  image_id      = "ami-07ef3a922fc0bdb35" # You can use this as a dynamic value if specified in TFVars

  user_data = base64encode(<<EOF
#!/bin/bash
/etc/eks/bootstrap.sh ${aws_eks_cluster.demo.name}
EOF
  )

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      "Name" = "eks-worker-node"
    }
  }
}

resource "aws_iam_role" "nodes" {
  name = "eks-node-group-nodes"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

# Define the Auto Scaling Group for EKS Worker Nodes
resource "aws_autoscaling_group" "eks_asg" {
  service_linked_role_arn = aws_iam_role.nodes.arn
  desired_capacity          = 2
  min_size                  = 1
  max_size                  = 5
  vpc_zone_identifier       = [
      var.private_subnet_1_id,
      var.private_subnet_2_id,
      var.private_subnet_3_id,
      var.public_subnet_1_id,
      var.public_subnet_2_id,
      var.public_subnet_3_id
    ]
  health_check_type         = "EC2"
  health_check_grace_period = 300

  # Define Mixed Instances Policy with On-Demand and Spot Instances
  mixed_instances_policy {
    instances_distribution {
      on_demand_percentage_above_base_capacity = 20
      spot_allocation_strategy                 = "capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.eks_launch_template.id
        version            = "$Latest"
      }
    }
  }

  # Define Tags for Auto Scaling Group (Note the use of "tag" block)
  tag {
    key                 = "centos-eks"
    value               = "eks-asg"
    propagate_at_launch = true
  }
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