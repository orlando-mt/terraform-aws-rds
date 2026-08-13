variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC for the cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets (at least 2 AZs)"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Application security group allowed to connect"
  type        = string
}
