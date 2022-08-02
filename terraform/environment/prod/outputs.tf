output "ctm_sg_id" {
  description = "Security Group"
  value       = module.create_common_infra.ctm_sg_id
}

output "private_hosted_zone_id" {
  description = "Private Hosted Zone_id"
  value       = module.create_common_infra.private_hosted_zone_id
}

output "public_hosted_zone_id" {
  description = "Public Hosted Zone_id"
  value       = module.create_common_infra.public_hosted_zone_id
}

output "software_efs_arn" {
  description = "Software EFS arn"
  value       = module.create_common_infra.software_efs_arn
}

output "software_efs_id" {
  description = "Software EFS id"
  value       = module.create_common_infra.software_efs_id
}

output "software_efs_dns_name" {
  description = "Software EFS dns_name"
  value       = module.create_common_infra.software_efs_dns_name
}
