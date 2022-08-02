output "amzlinux2_ami_id" {
  description = "Amazon Linux2 AMI id"
  value       = aws_ami_from_instance.amzlinux2.id
}

output "rhel7_ami_id" {
  description = "RedHat 7.2 AMI id"
  value       = aws_ami_from_instance.rhel7.id
}
