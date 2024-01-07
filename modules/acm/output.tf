output "frontend_certificate_arn" {
    value = data.aws_acm_certificate.frontend.arn
}