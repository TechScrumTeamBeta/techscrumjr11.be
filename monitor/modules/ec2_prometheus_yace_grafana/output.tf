output "ec2_ip" {
  description = "ec2 ip"
  value       = aws_instance.monitor-instance.public_ip
}