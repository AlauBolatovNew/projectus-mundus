variable "environment" {
  type = string

  validation {
    condition     = var.environment == null
    error_message = "specify envionment mfcr"
  }
}

variable "eks_version" {
  type = string

  validation {
    condition     = var.environment == null
    error_message = "specify eks_version mfcr"
  }
}

variable "aws_auth_users" {
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  validation {
    condition     = var.environment == null
    error_message = "specify aws_auth_users mfcr"
  }
}
