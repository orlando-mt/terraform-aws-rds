locals {
  # Derive the parameter group family from the engine major version
  # (e.g. 16.4 -> aurora-postgresql16). Falls back to var.parameter_group_family.
  parameter_group_family = coalesce(
    var.parameter_group_family,
    var.engine_version != null ? "aurora-postgresql${split(".", var.engine_version)[0]}" : "aurora-postgresql16"
  )

  is_serverless_v2 = var.cluster_type == "serverlessv2"
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.cluster_name}-subnet-group"
  subnet_ids = var.subnets
  tags       = var.tags
}

resource "aws_rds_cluster_parameter_group" "this" {
  name   = "${var.cluster_name}-parameter-group"
  family = local.parameter_group_family

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = var.tags
}

resource "aws_rds_cluster" "this" {
  # checkov:skip=CKV2_AWS_8:AWS Backup plans are an organization-level concern managed outside this module; the cluster has native backups (backup_retention_period, default 30 days) and a final snapshot by default
  # checkov:skip=CKV2_AWS_27:Query logging is available via cluster_parameters (log_statement, log_min_duration_statement). Not enabled by default: log_statement=all impacts performance and may capture sensitive data in logs
  cluster_identifier = var.cluster_name
  engine             = "aurora-postgresql"
  engine_mode        = "provisioned" # serverless v2 also uses provisioned mode
  engine_version     = var.engine_version
  database_name      = var.database_name

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name
  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.this.id]

  # Credentials: managed by Secrets Manager or provided explicitly
  master_username             = var.master_username
  manage_master_user_password = var.manage_master_user_password ? true : null
  master_password             = var.manage_master_user_password ? null : var.master_password

  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  # Backups and maintenance
  apply_immediately            = var.apply_immediately
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  copy_tags_to_snapshot        = true
  skip_final_snapshot          = var.skip_final_snapshot
  final_snapshot_identifier    = var.skip_final_snapshot ? null : "${var.cluster_name}-final-snapshot"

  # Protection and encryption
  deletion_protection = var.deletion_protection
  storage_encrypted   = true
  kms_key_id          = var.kms_key_id

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  dynamic "serverlessv2_scaling_configuration" {
    for_each = local.is_serverless_v2 ? [1] : []
    content {
      min_capacity = var.serverless_v2_min_capacity
      max_capacity = var.serverless_v2_max_capacity
    }
  }

  tags = var.tags
}

resource "aws_rds_cluster_instance" "this" {
  # checkov:skip=CKV_AWS_354:CMK encryption for Performance Insights is available via performance_insights_kms_key_id; the default uses the AWS-managed key
  count = var.instance_count

  identifier         = "${var.cluster_name}-instance-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.this.id
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version

  instance_class = local.is_serverless_v2 ? "db.serverless" : var.instance_class
  promotion_tier = count.index

  apply_immediately            = var.apply_immediately
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  preferred_maintenance_window = var.preferred_maintenance_window

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null

  monitoring_interval = var.enhanced_monitoring_interval
  monitoring_role_arn = var.enhanced_monitoring_interval > 0 ? aws_iam_role.enhanced_monitoring[0].arn : null

  tags = var.tags
}

# ---------------------------------------------------------------------------
# IAM role for RDS Enhanced Monitoring (created when the interval > 0)
# ---------------------------------------------------------------------------

resource "aws_iam_role" "enhanced_monitoring" {
  count = var.enhanced_monitoring_interval > 0 ? 1 : 0

  name = "${var.cluster_name}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "monitoring.rds.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  count = var.enhanced_monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
