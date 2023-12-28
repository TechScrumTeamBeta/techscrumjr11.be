output "OPENSEARCH_ENDPOINT" {
  description = "OPENSEARCH_ENDPOINT"
  value       = aws_opensearch_domain.logs_opensearch_domain.endpoint
}

output "OPENSEARCH_URL" {
  description = "OPENSEARCH_URL"
  value       = aws_opensearch_domain.logs_opensearch_domain.dashboard_endpoint
}