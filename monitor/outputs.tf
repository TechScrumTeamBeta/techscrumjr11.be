output "OPENSEARCH_URL" {
  description = "OPENSEARCH_URL"
  value       = module.opensearch_cluster.OPENSEARCH_URL
}

output "role_arn" {
  description = "arn of the lambda role"
  value       = module.lambda_role_module.role_arn
}

output "ec2_ip" {
  description = "ec2 ip"
  value       = module.ec2_prometheus_yace_grafana.ec2_ip
}