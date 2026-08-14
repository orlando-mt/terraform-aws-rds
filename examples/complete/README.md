# Complete example

Creates an Aurora PostgreSQL Serverless v2 cluster with:

- 1 writer + 1 reader (both `db.serverless`), 0.5-8 ACUs
- Credentials managed by AWS Secrets Manager
- Access restricted to the application's security group

Switching to a provisioned cluster is a two-line change in
[`terraform.tfvars`](./terraform.tfvars) — see the commented block there.

## Usage

```bash
terraform init
terraform plan
terraform apply
```
