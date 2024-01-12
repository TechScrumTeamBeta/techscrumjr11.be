# Create ecs cluster
resource "aws_ecs_cluster" "techscrum" {
  name = var.cluster_name
  //open conteainerinsights
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Create ecs service
resource "aws_ecs_service" "techscrum-backend" {
  name                              = "techscrum-${var.environment}"
  cluster                           = aws_ecs_cluster.techscrum.id
  task_definition                   = var.task_definition_arn
  desired_count                     = 2
  health_check_grace_period_seconds = 30
  launch_type                       = "FARGATE"
  scheduling_strategy               = "REPLICA"

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

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.techscrum.name}/${aws_ecs_service.techscrum-backend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 60
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}
