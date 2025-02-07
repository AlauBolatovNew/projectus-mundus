resource "aws_eks_cluster" "demo" {
  name     = "${var.environment}-eks"
  role_arn = aws_iam_role.demo.arn
  version  = var.eks_version

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]

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

# Define the Launch Template for Worker Nodes
resource "aws_launch_template" "eks_launch_template" {
  name_prefix   = "eks-node-"
  instance_type = "t3.medium"
  image_id      = "ami-088b41ffb0933423f" # You can use this as a dynamic value if specified in TFVars

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

# Define the Auto Scaling Group for EKS Worker Nodes
resource "aws_autoscaling_group" "eks_asg" {
  desired_capacity = 2
  min_size         = 5
  max_size         = 1
  vpc_zone_identifier = [
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
