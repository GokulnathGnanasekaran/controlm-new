output "primary_ctmarc_id" {
  description = "Primary CTMARC id"
  value       = aws_instance.ctmarc[0].id
}

#output "failover_ctmarc_id" {
#  description = "Failover CTMARC id"
#  value       = aws_instance.ctmarc[1].id
#}
