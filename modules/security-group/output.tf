output "alb_security_group_id" {
  value = aws_security_group.alb-sg.id
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs-sg.id
}