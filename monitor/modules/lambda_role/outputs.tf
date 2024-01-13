
output "role_arn" {
  description = "arn of the lambda role"
  value       = aws_iam_role.custlogstreamrole.arn
}