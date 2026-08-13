# terraform-aws-rds

Terraform module to create an Amazon Aurora PostgreSQL cluster in provisioned or Serverless v2 mode, with instances, parameter group and a dedicated security group.

## Features

- Two cluster types: `provisioned` (fixed instance class) and `serverlessv2` (`db.serverless` instances with ACU-based scaling, including scale-to-zero with `min_capacity = 0`)
- N instances with automatic promotion tiers — readers supported in both modes
- **Master password managed by AWS Secrets Manager by default** (`manage_master_user_password`) — no credentials in code or state
- Parameter group family derived from the engine version, with custom cluster parameters support
- Dedicated security group with granular ingress rules per source SG and/or CIDR (modern `aws_vpc_security_group_*_rule` resources)
- Storage encryption (default `aws/rds` key or custom KMS), deletion protection and final snapshot enabled by default
- Performance Insights (optional CMK encryption), Enhanced Monitoring with auto-created IAM role, CloudWatch log exports and IAM database authentication enabled by default
- Cross-field validations: instance class required for provisioned, capacity ranges, password requirements

## Usage

```hcl
module "aurora" {
  source = "github.com/orlando-mt/terraform-aws-rds?ref=v1.0.0"

  cluster_name = "my-app-db"
  cluster_type = "serverlessv2"

  engine_version = "16.4"
  database_name  = "appdb"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnet_ids

  master_username             = "dbadmin"
  manage_master_user_password = true

  instance_count             = 2
  serverless_v2_min_capacity = 0.5
  serverless_v2_max_capacity = 16

  inbound_sg_permitted = [module.eks.node_security_group_id]

  kms_key_id = module.kms.key_arns["rds"] # optional, defaults to aws/rds

  tags = {
    Project   = "my-project"
    ManagedBy = "terraform"
  }
}
```

> **Note on Serverless v1:** this module intentionally supports only provisioned and Serverless v2. Aurora Serverless v1 reached end of support (December 2024) and cannot be created anymore; v2 covers its use cases, including auto-pause via `serverless_v2_min_capacity = 0`.

> **Tip:** with `manage_master_user_password = true` (default), read the credentials from the secret in the `master_user_secret_arn` output. Pairs with [terraform-aws-kms](https://github.com/orlando-mt/terraform-aws-kms) for a customer-managed encryption key.

## Examples

- [Complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.0 |
| aws | >= 5.0 |

## Resources

| Name | Type |
|------|------|
| aws_rds_cluster.this | resource |
| aws_rds_cluster_instance.this | resource |
| aws_db_subnet_group.this | resource |
| aws_rds_cluster_parameter_group.this | resource |
| aws_security_group.this | resource |
| aws_vpc_security_group_ingress_rule.from_security_groups | resource |
| aws_vpc_security_group_ingress_rule.from_cidr_blocks | resource |
| aws_vpc_security_group_egress_rule.all_outbound | resource |
| aws_iam_role.enhanced_monitoring | resource |
| aws_iam_role_policy_attachment.enhanced_monitoring | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Cluster identifier | `string` | n/a | yes |
| cluster_type | provisioned or serverlessv2 | `string` | n/a | yes |
| vpc_id | VPC ID | `string` | n/a | yes |
| subnets | Subnets for the DB subnet group | `list(string)` | n/a | yes |
| master_username | Master username | `string` | n/a | yes |
| manage_master_user_password | Manage password in Secrets Manager | `bool` | `true` | no |
| master_password | Explicit password (fallback) | `string` | `null` | no |
| iam_database_authentication_enabled | IAM DB auth | `bool` | `true` | no |
| engine_version | Engine version | `string` | `null` | no |
| parameter_group_family | Family override | `string` | `null` (derived) | no |
| cluster_parameters | Custom cluster parameters | `list(object)` | `[]` | no |
| database_name | Initial database name | `string` | `null` | no |
| instance_count | Instances (1-15) | `number` | `2` | no |
| instance_class | Class for provisioned mode | `string` | `null` | no |
| serverless_v2_min_capacity | Min ACUs (0 = auto-pause) | `number` | `0.5` | no |
| serverless_v2_max_capacity | Max ACUs | `number` | `4` | no |
| port | Database port | `number` | `5432` | no |
| inbound_sg_permitted | Source SGs allowed | `list(string)` | `[]` | no |
| inbound_cidr_permitted | Source CIDRs allowed | `list(string)` | `[]` | no |
| apply_immediately | Apply changes immediately | `bool` | `false` | no |
| backup_retention_period | Backup retention (1-35 days) | `number` | `30` | no |
| preferred_backup_window | Backup window (UTC) | `string` | `"08:00-11:00"` | no |
| preferred_maintenance_window | Maintenance window | `string` | `"mon:03:00-mon:04:00"` | no |
| skip_final_snapshot | Skip final snapshot | `bool` | `false` | no |
| auto_minor_version_upgrade | Auto minor upgrades | `bool` | `true` | no |
| deletion_protection | Deletion protection | `bool` | `true` | no |
| kms_key_id | Custom KMS key ARN | `string` | `null` (aws/rds) | no |
| enabled_cloudwatch_logs_exports | Logs to export | `list(string)` | `["postgresql"]` | no |
| performance_insights_enabled | Performance Insights | `bool` | `true` | no |
| performance_insights_retention_period | PI retention (days) | `number` | `7` | no |
| performance_insights_kms_key_id | CMK for PI encryption | `string` | `null` | no |
| enhanced_monitoring_interval | Enhanced Monitoring seconds (0 = off) | `number` | `60` | no |
| tags | Tags for all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id / cluster_arn | Cluster identity |
| cluster_endpoint | Writer endpoint |
| cluster_reader_endpoint | Reader endpoint |
| database_name | Initial database |
| port | Database port |
| master_username | Master username |
| master_user_secret_arn | Secrets Manager secret ARN |
| instance_ids / instance_endpoints | Instance details |
| security_group_id | Security group ID |
<!-- END_TF_DOCS -->

## License

MIT. See [LICENSE](./LICENSE).
