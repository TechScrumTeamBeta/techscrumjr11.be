














# Create ecs cluster
resource "aws_ecs_cluster" "techscrum" {
  name = var.cluster_name

  //open conteainerinsights
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
   tags = {
    Name        = var.cluster_name
    environment = var.environment
  }
}

# Create ecs service
resource "aws_ecs_service" "service" {
  name                              = "techscrum-${var.environment}"
  cluster                           = aws_ecs_cluster.techscrum.id
  # task_definition                   = var.task_definition_arn
  task_definition                   = aws_ecs_task_definition.backend.arn
  desired_count                     = 2
  health_check_grace_period_seconds = 30
  launch_type                       = "FARGATE"
  # scheduling_strategy               = "REPLICA"

  enable_execute_command = true

  network_configuration {
    subnets          = var.environment == "uat" ? var.public_subnets_ids : var.private_subnets_ids
    assign_public_ip = true
    security_groups  = [var.ecs_security_group_id]
  }

  force_new_deployment = true
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "techscrum"
    container_port   = 8000
  }

  tags = {
    Name = "${var.projectName}-ecs_service-${var.environment}"
  }
}

#######################################################################################################################
#                                               Auto Scale Group
#######################################################################################################################
resource "aws_appautoscaling_target" "ecs_scale_target" {
  resource_id        = "service/${aws_ecs_cluster.techscrum.name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  min_capacity       = var.task_min_count
  max_capacity       = var.task_max_count
}



resource "aws_appautoscaling_policy" "scale_up_policy" {
  name               = "${aws_ecs_service.service.name}-scale-up-policy-${var.environment}"
  service_namespace  = aws_appautoscaling_target.ecs_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_scale_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "scale_down_policy" {
  name               = "${aws_ecs_service.service.name}-scale-down-policy-${var.environment}"
  service_namespace  = aws_appautoscaling_target.ecs_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_scale_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

# Create target tracking scaling policy using metric math
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${aws_ecs_service.service.name}-cpu-high-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "80"
  alarm_actions       = [aws_appautoscaling_policy.scale_up_policy.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.techscrum.name
    ServiceName = aws_ecs_service.service.name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${aws_ecs_service.service.name}-cpu-low-${var.environment}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "20"
  alarm_actions       = [aws_appautoscaling_policy.scale_down_policy.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.techscrum.name
    ServiceName = aws_ecs_service.service.name
  }
}