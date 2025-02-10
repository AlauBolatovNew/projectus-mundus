variable "private_subnet_1_id" {
  type = string
}

variable "private_subnet_2_id" {
  type = string
}

variable "private_subnet_3_id" {
  type = string
}

variable "public_subnet_1_id" {
  type = string
}

variable "public_subnet_2_id" {
  type = string
}

variable "public_subnet_3_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "security_group_id" {
  description = "Security group ID for the EKS nodes"
  type        = string
}