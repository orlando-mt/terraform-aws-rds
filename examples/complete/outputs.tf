output "writer_endpoint" {
  description = "Writer endpoint"
  value       = module.aurora_serverless.cluster_endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint"
  value       = module.aurora_serverless.cluster_reader_endpoint
}

output "master_user_secret_arn" {
  description = "Secrets Manager secret with the credentials"
  value       = module.aurora_serverless.master_user_secret_arn
}
