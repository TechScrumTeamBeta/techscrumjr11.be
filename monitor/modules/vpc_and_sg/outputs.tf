output "monitor_sg_id" {
  description = "The monitor sg id"
  value       = aws_security_group.monitor-sg.id
}

output "subnet_id" {
  description = "The ID of the first subnet"
  value       = aws_subnet.monitor-public-subnet[0].id
}