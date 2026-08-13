provider "aws" {
  region = var.region
}

module "aurora_serverless" {
  source = "../../"

  cluster_name = "example-aurora"
  cluster_type = "serverlessv2"

  engine_version = "16.4"
  database_name  = "appdb"

  vpc_id  = var.vpc_id
  subnets = var.private_subnet_ids

  # Credentials in Secrets Manager (no password in code or state)
  master_username             = "dbadmin"
  manage_master_user_password = true

  # 1 writer + 1 reader, both serverless
  instance_count             = 2
  serverless_v2_min_capacity = 0.5
  serverless_v2_max_capacity = 8

  inbound_sg_permitted = [var.app_security_group_id]

  tags = {
    Project   = "example"
    ManagedBy = "terraform"
  }
}
