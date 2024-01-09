output "acm-cert-arn" {
  value = aws_acm_certificate.cert.arn
}


output "acm-cert-arn-asterisk" {
  value = aws_acm_certificate.cert_asterisk.arn
}