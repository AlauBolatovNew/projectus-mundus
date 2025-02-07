variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_role_arn" {
  description = "IAM role ARN for EKS cluster"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs for the EKS nodes"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for the EKS nodes"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the worker nodes"
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