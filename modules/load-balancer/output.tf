output "target_group_arn" {
    value = aws_lb_target_group.tg.arn
}

output "alb_dns_name" {
    value = aws_lb.alb.dns_name
}


output "alb_zone_id" {
    value = aws_lb.alb.zone_id
}

output "alb_arn_suffix" {
  description = "alb arn suffix"
  value       = aws_lb.alb.arn_suffix
}

output "alb_arn" {
  value = aws_lb.alb.arn
}