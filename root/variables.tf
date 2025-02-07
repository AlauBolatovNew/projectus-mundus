variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "Availability Zones for the subnets"
  type        = list(string)
}

variable "public_subnet_cidr_blocks" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnet_cidr_blocks" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
}

variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "cluster_role_arn" {
  description = "IAM role ARN for the EKS cluster"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the worker nodes"
  type        = string
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "on_demand_percentage" {
  description = "Percentage of on-demand instances"
  type        = number
}

variable "environment" {
  description = "The environment name (dev, staging, prod)"
  type        = string
}