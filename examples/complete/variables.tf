variable "region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "Cluster identifier"
  type        = string
}

variable "cluster_type" {
  description = "provisioned or serverlessv2"
  type        = string
}

variable "engine_version" {
  description = "Aurora PostgreSQL version"
  type        = string
  default     = null
}

variable "database_name" {
  description = "Initial database name"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC where the cluster is created"
  type        = string
}

variable "subnets" {
  description = "Private subnets for the cluster (at least 2 AZs)"
  type        = list(string)
}

variable "master_username" {
  description = "Master username (password is managed by Secrets Manager)"
  type        = string
}

variable "instance_count" {
  description = "Number of instances (writer + readers)"
  type        = number
  default     = 2
}

variable "instance_class" {
  description = "Instance class (provisioned clusters only)"
  type        = string
  default     = null
}

variable "serverless_v2_min_capacity" {
  description = "Minimum ACUs (0 enables auto-pause)"
  type        = number
  default     = 0.5
}

variable "serverless_v2_max_capacity" {
  description = "Maximum ACUs"
  type        = number
  default     = 4
}

variable "inbound_sg_permitted" {
  description = "Security groups allowed to connect"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
