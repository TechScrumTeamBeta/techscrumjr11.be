output  "cloudwatch_group_name" {
    value = aws_cloudwatch_log_group.log_group_ecs_fargate.name
}