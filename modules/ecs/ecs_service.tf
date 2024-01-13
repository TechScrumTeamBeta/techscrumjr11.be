#############################################################################################################
#                                    ecsTaskExecutionRole 
############################################################################################################

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
data "aws_ssm_parameters_by_path" "config_params" {
  path = "/techscrum/"
}

# data "aws_ssm_parameter" "ssm_params" {
#   for_each = toset(data.aws_ssm_parameters_by_path.config_params.names)
#   name     = each.value
# }
# locals {
#   ssm_values = {
#     for name, param in data.aws_ssm_parameter.ssm_params : name => param.value
#   }
# }


data "aws_ssm_parameter" "environment" {
  name = "/techscrum/ENVIRONMENT"
}

data "aws_ssm_parameter" "name" {
  name = "/techscrum/NAME"
}

data "aws_ssm_parameter" "port" {
  name = "/techscrum/PORT"
}

data "aws_ssm_parameter" "api_prefix" {
  name = "/techscrum/API_PREFIX"
}

data "aws_ssm_parameter" "region" {
  name = "/techscrum/REGION"
}

data "aws_ssm_parameter" "access_key_id" {
  name = "/techscrum/ACCESS_KEY_ID"
}

data "aws_ssm_parameter" "secret_access_key" {
  name = "/techscrum/SECRET_ACCESS_KEY"
}

data "aws_ssm_parameter" "access_secret" {
  name = "/techscrum/ACCESS_SECRET"
}

data "aws_ssm_parameter" "email_secret" {
  name = "/techscrum/EMAIL_SECRET"
}

data "aws_ssm_parameter" "forget_secret" {
  name = "/techscrum/FORGET_SECRET"
}

data "aws_ssm_parameter" "limiter" {
  name = "/techscrum/LIMITER"
}

data "aws_ssm_parameter" "main_domain" {
  name = "/techscrum/MAIN_DOMAIN"
}

data "aws_ssm_parameter" "public_connection" {
  name = "/techscrum/PUBLIC_CONNECTION"
}

data "aws_ssm_parameter" "tenants_connection" {
  name = "/techscrum/TENANTS_CONNECTION"
}

data "aws_ssm_parameter" "stripe_private_key" {
  name = "/techscrum/STRIPE_PRIVATE_KEY"
}

data "aws_ssm_parameter" "stripe_webhook_secret" {
  name = "/techscrum/STRIPE_WEBHOOK_SECRET"
}



# Create task definition
resource "aws_ecs_task_definition" "ecs_task" {
  family = "techscrum-backend-${var.environment}"
    requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 3072
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.task_role_arn
  container_definitions = jsonencode(
    [
      {
        "name" : "techscrum-container-${var.environment}",
        "image" : "${var.imageURI}",
        "cpu" : 0,
        "memory" : 300,
        "essential" : true,
        "portMappings" : [
          {
            "containerPort" : 8000,
            "hostPort" : 8000
             protocol      = "tcp"
          }
        ],
        # 添加healthcheck
        healthCheck = {
          command     = ["CMD-SHELL", "curl -f http://localhost:8000/api/v2/healthcheck || exit 1"]
          interval    = 30
          timeout     = 5
          retries     = 3
          startPeriod = 0
        },


  
        
        # 如果 var.environment 不是 "prod"，则不设置任何环境变量

        "logConfiguration" : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-group" : "${var.cloudwatch_group_name}",
            "awslogs-region" : "${var.region}",
            "awslogs-stream-prefix" : "ecs-${var.environment}"
          }
        },
  
          environment = [
          { name = "ENVIRONMENT", value = data.aws_ssm_parameter.environment.value },
          { name = "NAME", value = data.aws_ssm_parameter.name.value },
          { name = "PORT", value = data.aws_ssm_parameter.port.value },
          { name = "API_PREFIX", value = data.aws_ssm_parameter.api_prefix.value },
          { name = "AWS_REGION", value = data.aws_ssm_parameter.region.value },
          { name = "AWS_ACCESS_KEY_ID", value = data.aws_ssm_parameter.access_key_id.value },
          { name = "AWS_SECRET_ACCESS_KEY", value = data.aws_ssm_parameter.secret_access_key.value },
          { name = "ACCESS_SECRET", value = data.aws_ssm_parameter.access_secret.value },
          { name = "EMAIL_SECRET", value = data.aws_ssm_parameter.email_secret.value },
          { name = "FORGET_SECRET", value = data.aws_ssm_parameter.forget_secret.value },
          { name = "LIMITER", value = data.aws_ssm_parameter.limiter.value },
          { name = "MAIN_DOMAIN", value = data.aws_ssm_parameter.main_domain.value },
          { name = "PUBLIC_CONNECTION", value = data.aws_ssm_parameter.public_connection.value },
          { name = "TENANTS_CONNECTION", value = data.aws_ssm_parameter.tenants_connection.value },
          { name = "STRIPE_PRIVATE_KEY", value = data.aws_ssm_parameter.stripe_private_key.value },
          { name = "STRIPE_WEBHOOK_SECRET", value = data.aws_ssm_parameter.stripe_webhook_secret.value },
        ]
      }
  ])

  tags = {
    Name = "${var.projectName}-task_definition-${var.environment}"
  }
}









#######################################################################################################################
#                                               Create ECS
#######################################################################################################################



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
  task_definition                   = aws_ecs_task_definition.ecs_task.arn
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
    container_name   = "techscrum-container-${var.environment}"
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
# 如cpuutilization是不使用 container insigts 来获得cloud watch metric。
#如果开启container insights 会有新的metric
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
  threshold           = "10"
  alarm_actions       = [aws_appautoscaling_policy.scale_down_policy.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.techscrum.name
    ServiceName = aws_ecs_service.service.name
  }
}