output "vpc_id" {
  description = "VPC id"
  value       = data.aws_vpc.selected.id
}

output "ctm_subnet_1a_id" {
  description = "CTM Subnet 1a id"
  value       = data.aws_subnet.ctm_sub_1a.id
}

output "ctm_subnet_1b_id" {
  description = "CTM Subnet 1b id"
  value       = data.aws_subnet.ctm_sub_1b.id
}

output "ctm_sg_id" {
  description = "Security Group id"
  value       = aws_security_group.security.id
}

output "private_hosted_zone_id" {
  description = "Private Hosted Zone id"
  value       = aws_route53_zone.private.zone_id
}

output "public_hosted_zone_id" {
  description = "Public Hosted Zone id"
  value       = aws_route53_zone.public.zone_id
}

output "software_efs_arn" {
  description = "Software EFS arn"
  value       = aws_efs_file_system.software_efs.arn
}

output "software_efs_id" {
  description = "Software EFS id"
  value       = aws_efs_file_system.software_efs.id
}

output "software_efs_dns_name" {
  description = "Software EFS dnsname"
  value       = aws_efs_file_system.software_efs.dns_name
}

output "iam_instance_profile_name" {
  description = "IAM Instance Profile"
  value       = aws_iam_instance_profile.profile.name
}

output "ssm_endpoint" {
  description = "SSM Endpoint"
  value       = lookup(aws_vpc_endpoint.ssm.dns_entry[0], "dns_name")
}
