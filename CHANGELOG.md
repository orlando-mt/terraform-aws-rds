# Changelog

## [1.0.0] - 2026-07-30

### Added
- Initial release: Aurora PostgreSQL cluster in provisioned or
  serverless v2 mode with N instances and promotion tiers
- Master password managed by AWS Secrets Manager by default
- Parameter group family derived from the engine version, with custom
  cluster parameters support
- Dedicated security group with granular ingress rules per source SG/CIDR
- Encryption at rest, deletion protection and final snapshot by default
- Performance Insights (optional CMK), Enhanced Monitoring with
  auto-created IAM role, CloudWatch log exports and IAM database
  authentication enabled by default
