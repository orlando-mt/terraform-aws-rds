provider "aws" {
  region = var.region
}

module "aurora" {
  source = "../../"

  cluster_name = var.cluster_name
  cluster_type = var.cluster_type

  engine_version = var.engine_version
  database_name  = var.database_name

  vpc_id  = var.vpc_id
  subnets = var.subnets

  master_username             = var.master_username
  manage_master_user_password = true

  instance_count = var.instance_count
  instance_class = var.instance_class

  serverless_v2_min_capacity = var.serverless_v2_min_capacity
  serverless_v2_max_capacity = var.serverless_v2_max_capacity

  inbound_sg_permitted = var.inbound_sg_permitted

  tags = var.tags
}
