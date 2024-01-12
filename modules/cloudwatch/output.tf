output  "cloudwatch_group_name" {
    value = aws_cloudwatch_log_group.ecs_fargate.name
}