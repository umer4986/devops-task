variable "region" {
  description = "AWS region"
  default     = "eu-central-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  default     = "dev"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  default     = "devops-task"
}
