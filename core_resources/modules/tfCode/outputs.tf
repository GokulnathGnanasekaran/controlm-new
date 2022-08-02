
output "amzlinux2_id" {
  description = "Amazon Linux2 id"
  value       = aws_instance.ami_copy[0].id
}

output "rhel7_id" {
  description = "RedHat 7.2 id"
  value       = aws_instance.ami_copy[1].id
}
