resource "aws_launch_template" "eks_template" {
  instance_type = "t3.medium"
  image_id = "ami-088b41ffb0933423f"

  depends_on = [aws_eks_cluster.demo]
}

resource "aws_autoscaling_group" "eks_autoscale" {
  min_size         = 1
  max_size         = 5
  desired_capacity = 3

  vpc_zone_identifier = [
    var.private_subnet_1_id,
    var.private_subnet_2_id,
    var.private_subnet_3_id
  ]

  mixed_instances_policy {

    instances_distribution {
      on_demand_percentage_above_base_capacity = 20
      spot_allocation_strategy                 = "lowest-price"
      on_demand_base_capacity                  = 0
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.eks_template.id
      }
    }
  }

  tag {
    key                 = "kubernetes.io/cluster/${aws_eks_cluster.demo.name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${aws_eks_cluster.demo.name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
