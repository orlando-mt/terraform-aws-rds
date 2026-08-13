# Complete example

Creates an Aurora PostgreSQL Serverless v2 cluster with:

- 1 writer + 1 reader (both `db.serverless`), 0.5-8 ACUs
- Credentials managed by AWS Secrets Manager
- Access restricted to the application's security group

For a provisioned cluster, set `cluster_type = "provisioned"` and an
`instance_class` (e.g. `db.r6g.large`).

## Usage

```bash
terraform init
terraform apply \
  -var "vpc_id=vpc-xxxx" \
  -var 'private_subnet_ids=["subnet-a","subnet-b"]' \
  -var "app_security_group_id=sg-cccc"
```
