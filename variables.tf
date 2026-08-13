variable "cluster_name" {
  description = "Cluster identifier"
  type        = string
}

variable "cluster_type" {
  description = "Cluster type: 'provisioned' or 'serverlessv2'"
  type        = string

  validation {
    condition     = contains(["provisioned", "serverlessv2"], var.cluster_type)
    error_message = "cluster_type must be 'provisioned' or 'serverlessv2'."
  }
}

variable "engine_version" {
  description = "Aurora PostgreSQL engine version (null lets AWS pick the default). The parameter group family is derived from its major version"
  type        = string
  default     = null
}

variable "parameter_group_family" {
  description = "Override for the cluster parameter group family (derived from engine_version when null)"
  type        = string
  default     = null
}

variable "cluster_parameters" {
  description = "Cluster parameter group entries"
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "pending-reboot")
  }))
  default = []
}

variable "database_name" {
  description = "Name of the initial database to create (optional)"
  type        = string
  default     = null
}

# --- Instances -------------------------------------------------------------

variable "instance_count" {
  description = "Number of cluster instances (writer + readers). Applies to both provisioned and serverless v2"
  type        = number
  default     = 2

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 15
    error_message = "instance_count must be between 1 and 15."
  }
}

variable "instance_class" {
  description = "Instance class for provisioned clusters (ignored for serverless v2)"
  type        = string
  default     = null

  validation {
    condition     = var.cluster_type != "provisioned" || var.instance_class != null
    error_message = "instance_class is required when cluster_type is 'provisioned'."
  }
}

# --- Serverless v2 scaling -------------------------------------------------

variable "serverless_v2_min_capacity" {
  description = "Serverless v2 minimum ACUs (0 enables auto-pause)"
  type        = number
  default     = 0.5

  validation {
    condition     = var.serverless_v2_min_capacity >= 0 && var.serverless_v2_min_capacity <= 256
    error_message = "serverless_v2_min_capacity must be between 0 and 256 ACUs."
  }
}

variable "serverless_v2_max_capacity" {
  description = "Serverless v2 maximum ACUs"
  type        = number
  default     = 4

  validation {
    condition     = var.serverless_v2_max_capacity >= 0.5 && var.serverless_v2_max_capacity <= 256
    error_message = "serverless_v2_max_capacity must be between 0.5 and 256 ACUs."
  }

  validation {
    condition     = var.serverless_v2_max_capacity >= var.serverless_v2_min_capacity
    error_message = "serverless_v2_max_capacity must be >= serverless_v2_min_capacity."
  }
}

# --- Credentials -----------------------------------------------------------

variable "master_username" {
  description = "Master username"
  type        = string
}

variable "manage_master_user_password" {
  description = "Let RDS manage the master password in AWS Secrets Manager (recommended). Mutually exclusive with master_password"
  type        = bool
  default     = true
}

variable "master_password" {
  description = "Master password (only used when manage_master_user_password is false)"
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition     = var.manage_master_user_password || (var.master_password != null && length(var.master_password) >= 8)
    error_message = "master_password (min 8 characters) is required when manage_master_user_password is false."
  }
}

variable "iam_database_authentication_enabled" {
  description = "Enable IAM database authentication"
  type        = bool
  default     = false
}

# --- Networking ------------------------------------------------------------

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnets" {
  description = "Subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "inbound_sg_permitted" {
  description = "Security group IDs allowed to connect"
  type        = list(string)
  default     = []
}

variable "inbound_cidr_permitted" {
  description = "CIDR blocks allowed to connect"
  type        = list(string)
  default     = []
}

# --- Backups and maintenance -----------------------------------------------

variable "apply_immediately" {
  description = "Apply changes immediately instead of during the maintenance window"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 30

  validation {
    condition     = var.backup_retention_period >= 1 && var.backup_retention_period <= 35
    error_message = "backup_retention_period must be between 1 and 35 days."
  }
}

variable "preferred_backup_window" {
  description = "Preferred backup window (UTC)"
  type        = string
  default     = "08:00-11:00"
}

variable "preferred_maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "mon:03:00-mon:04:00"
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot on deletion"
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades on instances"
  type        = bool
  default     = true
}

# --- Protection and encryption ---------------------------------------------

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ARN for storage encryption. If null, AWS uses the default aws/rds key"
  type        = string
  default     = null
}

# --- Observability ---------------------------------------------------------

variable "enabled_cloudwatch_logs_exports" {
  description = "Log types to export to CloudWatch"
  type        = list(string)
  default     = ["postgresql"]
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights on instances"
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention in days (7, 465 or 731)"
  type        = number
  default     = 7
}

# --- Tags ------------------------------------------------------------------

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
