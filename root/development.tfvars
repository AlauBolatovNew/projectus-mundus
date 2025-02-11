vpc_cidr_block             = "10.0.0.0/16"
azs                        = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnet_cidr_blocks  = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
cluster_name               = "dev-cluster"
cluster_role_arn           = "arn:aws:iam::864899873372:role/eks-cluster-role"
instance_type              = "t3.medium"

ami_id = "ami-070ee37f2c1386fd6"

desired_size         = 2
max_size             = 5
min_size             = 1
on_demand_percentage = 20
environment          = "dev"