region       = "us-east-1"
cluster_name = "example-aurora"
cluster_type = "serverlessv2"

engine_version = "16.4"
database_name  = "appdb"

vpc_id  = "vpc-00000000000000000"
subnets = ["subnet-00000000000000001", "subnet-00000000000000002"]

# Credentials are managed by Secrets Manager: no password in code or state
master_username = "dbadmin"

# 1 writer + 1 reader, both serverless
instance_count             = 2
serverless_v2_min_capacity = 0.5
serverless_v2_max_capacity = 8

# For a provisioned cluster instead:
#   cluster_type   = "provisioned"
#   instance_class = "db.r6g.large"

inbound_sg_permitted = ["sg-00000000000000000"]

tags = {
  Project   = "example"
  ManagedBy = "terraform"
}
