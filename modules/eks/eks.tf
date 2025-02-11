resource "aws_iam_role" "demo" {
  name = "eks-cluster-demo"
  tags = {
    tag-key = "eks-cluster-demo"
  }

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "eks.amazonaws.com"
          ]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "demo-AmazonEKSClusterPolicy" {
  role       = aws_iam_role.demo.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "eks_centos" {
  name     = var.cluster_name
  role_arn = aws_iam_role.demo.arn
  vpc_config {
    subnet_ids         = var.subnets
    security_group_ids = [var.security_group_id]
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  kubernetes_network_config {
    service_ipv4_cidr = "172.20.0.0/16"
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

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.nodes.name
}

# Define the Launch Template for Worker Nodes
resource "aws_launch_template" "eks_launch_template" {
  name_prefix   = "eks-node-"
  instance_type = var.instance_type
  image_id      = var.ami_id # You can use this as a dynamic value if specified in TFVars

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(<<EOF
#!/bin/bash
/etc/eks/bootstrap.sh ${aws_eks_cluster.eks_centos.name}
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

# Define the Auto Scaling Group for EKS Worker Nodes
resource "aws_autoscaling_group" "eks_asg" {
  desired_capacity          = var.desired_size
  min_size                  = var.min_size
  max_size                  = var.max_size
  vpc_zone_identifier       = var.subnets
  health_check_type         = "EC2"
  health_check_grace_period = 300

  # Define Mixed Instances Policy with On-Demand and Spot Instances
  mixed_instances_policy {
    instances_distribution {
      on_demand_percentage_above_base_capacity = var.on_demand_percentage
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
  cluster_name  = aws_eks_cluster.eks_centos.name
  principal_arn = "arn:aws:iam::864899873372:root"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "ss" {
  cluster_name  = aws_eks_cluster.eks_centos.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::864899873372:root"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_policy_association" "s5" {
  cluster_name  = aws_eks_cluster.eks_centos.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = "arn:aws:iam::864899873372:root"

  access_scope {
    type = "cluster"
  }
}
