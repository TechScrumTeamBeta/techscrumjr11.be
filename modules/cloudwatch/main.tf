resource "aws_cloudwatch_log_group" "ecs_fargate" {
  name = "ecs_fargate_${var.projectName}_${var.environment}"

  tags = {
    Name = "var.projectName-log-var.environment"
  }
}
