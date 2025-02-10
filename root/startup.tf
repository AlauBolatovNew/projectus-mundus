# module "sample_vpc" {
#   source      = "../modules/vpc"
#   cidr        = "10.10.0.0/16"
#   environment = var.environment
# }

# module "kubernetes_cluster" {
#   source = "../modules/eks"

#   environment = var.environment

#   private_subnet_1_id = module.sample_vpc.private_subnet_1_id
#   private_subnet_2_id = module.sample_vpc.private_subnet_2_id
#   private_subnet_3_id = module.sample_vpc.private_subnet_3_id
#   public_subnet_1_id  = module.sample_vpc.public_subnet_1_id
#   public_subnet_2_id  = module.sample_vpc.public_subnet_2_id
#   public_subnet_3_id  = module.sample_vpc.public_subnet_3_id

#   depends_on = [module.sample_vpc]
# }
