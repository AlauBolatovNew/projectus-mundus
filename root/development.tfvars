environment = "development"
eks_version = "1.32"
aws_auth_users = [
  {
    userarn  = "arn:aws:iam::864899873372:user/terraform"
    username = "terraform"
    groups   = ["system:masters"]
  },
  {
    userarn  = "arn:aws:iam::864899873372:user/alau"
    username = "alau"
    groups   = ["system:masters"]
  }
]
