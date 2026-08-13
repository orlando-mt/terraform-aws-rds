output "cluster_id" {
  description = "ID of the Aurora cluster"
  value       = aws_rds_cluster.this.id
}

output "cluster_arn" {
  description = "ARN of the Aurora cluster"
  value       = aws_rds_cluster.this.arn
}

output "cluster_endpoint" {
  description = "Writer endpoint of the cluster"
  value       = aws_rds_cluster.this.endpoint
}

output "cluster_reader_endpoint" {
  description = "Reader endpoint of the cluster"
  value       = aws_rds_cluster.this.reader_endpoint
}

output "database_name" {
  description = "Name of the initial database"
  value       = aws_rds_cluster.this.database_name
}

output "port" {
  description = "Database port"
  value       = aws_rds_cluster.this.port
}

output "master_username" {
  description = "Master username"
  value       = aws_rds_cluster.this.master_username
}

output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret with the master credentials (null if manage_master_user_password is false)"
  value       = try(aws_rds_cluster.this.master_user_secret[0].secret_arn, null)
}

output "instance_ids" {
  description = "IDs of the cluster instances"
  value       = aws_rds_cluster_instance.this[*].id
}

output "instance_endpoints" {
  description = "Endpoints of the cluster instances"
  value       = aws_rds_cluster_instance.this[*].endpoint
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.this.id
}
