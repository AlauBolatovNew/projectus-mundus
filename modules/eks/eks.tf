resource "aws_eks_cluster" "eks_centos" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  vpc_config {
    subnet_ids         = var.subnets
    security_group_ids = [var.security_group_id]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  kubernetes_network_config {
    service_ipv4_cidr = "172.20.0.0/16"
  }
}
# Define the Launch Template for Worker Nodes
resource "aws_launch_template" "eks_launch_template" {
  name_prefix   = "eks-node-"
  instance_type = var.instance_type
  image_id      = var.ami_id # You can use this as a dynamic value if specified in TFVars

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
