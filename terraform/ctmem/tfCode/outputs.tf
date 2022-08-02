output "primary_ctmem_id" {
  description = "Primary CTMEM id"
  value       = aws_instance.ctmem[0].id
}

output "primary_ctmem_dns" {
  description = "Primary CTMEM dns"
  value       = aws_instance.ctmem[0].private_dns
}

output "failover_ctmem_id" {
  description = "Failover CTMEM id"
  value       = aws_instance.ctmem[1].id
}

output "failover_ctmem_dns" {
  description = "Failover CTMEM dns"
  value       = aws_instance.ctmem[1].private_dns
}
