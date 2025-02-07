module "vpc" {
  source = "../modules/vpc"

  cidr_block                 = var.vpc_cidr_block
  azs                        = var.azs
  public_subnet_cidr_blocks  = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  environment                = var.environment
}

module "eks" {
  source = "../modules/eks"

  cluster_name         = var.cluster_name
  cluster_role_arn     = var.cluster_role_arn
  subnets              = module.vpc.public_subnets
  security_group_id    = module.vpc.eks_sg
  instance_type        = var.instance_type
  ami_id               = "ami-0c614dee691cbbf37" # Use the dynamically fetched AMI ID
  desired_size         = var.desired_size
  max_size             = var.max_size
  min_size             = var.min_size
  on_demand_percentage = var.on_demand_percentage
}