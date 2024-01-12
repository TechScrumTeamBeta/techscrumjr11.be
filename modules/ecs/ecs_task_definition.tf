data "aws_secretsmanager_secret_version" "mongo_secret" {
  secret_id = "uat-techscrum-back"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
# data "aws_ssm_parameters_by_path" "config_params" {
#   path = "/techscrum/"
# }

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
resource "aws_ecs_task_definition" "backend" {
  family = "backend"
  container_definitions = jsonencode(
    [
      {
        "name" : "techscrum",
        "image" : "${var.imageURI}",
        "cpu" : 0,
        "memory" : 1024,
        "essential" : true,
        "portMappings" : [
          {
            "containerPort" : 8000,
            "hostPort" : 8000
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


        environment = var.environment == "uat" ? [
          # { name = "ENVIRONMENT", value = local.ssm_values["/techscrum/ENVIRONMENT"] },
          # { name = "NAME", value = local.ssm_values["/techscrum/NAME"] },
          # { name = "PORT", value = local.ssm_values["/techscrum/PORT"] },
          # { name = "API_PREFIX", value = local.ssm_values["/techscrum/API_PREFIX"] },
          # { name = "AWS_REGION", value = local.ssm_values["/techscrum/REGION"] },
          # { name = "AWS_ACCESS_KEY_ID", value = local.ssm_values["/techscrum/ACCESS_KEY_ID"] },
          # { name = "AWS_SECRET_ACCESS_KEY", value = local.ssm_values["/techscrum/SECRET_ACCESS_KEY"] },
          # { name = "ACCESS_SECRET", value = local.ssm_values["/techscrum/ACCESS_SECRET"] },
          # { name = "EMAIL_SECRET", value = local.ssm_values["/techscrum/EMAIL_SECRET"] },
          # { name = "FORGET_SECRET", value = local.ssm_values["/techscrum/FORGET_SECRET"] },
          # { name = "LIMITER", value = local.ssm_values["/techscrum/LIMITER"] },
          # { name = "MAIN_DOMAIN", value = local.ssm_values["/techscrum/MAIN_DOMAIN"] },
          # { name = "PUBLIC_CONNECTION", value = local.ssm_values["/techscrum/PUBLIC_CONNECTION"] },
          # { name = "TENANTS_CONNECTION", value = local.ssm_values["/techscrum/TENANTS_CONNECTION"] },
          # { name = "STRIPE_PRIVATE_KEY", value = local.ssm_values["/techscrum/STRIPE_PRIVATE_KEY"] },
          # { name = "STRIPE_WEBHOOK_SECRET", value = local.ssm_values["/techscrum/STRIPE_WEBHOOK_SECRET"] }
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
          { name = "STRIPE_WEBHOOK_SECRET", value = data.aws_ssm_parameter.stripe_webhook_secret.value }
        ] : []
        # 如果 var.environment 不是 "prod"，则不设置任何环境变量




        # "environment" : [
        #   { "name" : "JWT_KEY",
        #     "value" : jsondecode(data.aws_secretsmanager_secret_version.mongo_secret.secret_string)["JWT_KEY"]
        #   },
        #   {
        #     "name" : "CONNECTION_STRING",
        #     "value" : jsondecode(data.aws_secretsmanager_secret_version.mongo_secret.secret_string)["CONNECTION_STRING"]
        #   },
        #   {
        #     "name" : "BUCKET",
        #     "value" : jsondecode(data.aws_secretsmanager_secret_version.container_secret.secret_string)["BUCKET"]
        #   },
        #   {
        #     "name" : "AWS_ACCESS_KEY_ID",
        #     "value" : jsondecode(data.aws_secretsmanager_secret_version.container_secret.secret_string)["AWS_ACCESS_KEY_ID"]
        #   },
        #   {
        #     "name" : "AWS_SECRET_ACCESS_KEY",
        #     "value" : jsondecode(data.aws_secretsmanager_secret_version.container_secret.secret_string)["AWS_SECRET_ACCESS_KEY"]
        #   },
        #   {
        #     "name" : "AWS_REGION",
        #     "value" : jsondecode(data.aws_secretsmanager_secret_version.container_secret.secret_string)["AWS_REGION"]
        #   }
        # ],
        # 使用ssm



        #    environment = [
        #   { name = "ENVIRONMENT", value = data.aws_ssm_parameter.environment.value },
        #   { name = "NAME", value = data.aws_ssm_parameter.name.value },
        #   { name = "PORT", value = data.aws_ssm_parameter.port.value },
        #   { name = "API_PREFIX", value = data.aws_ssm_parameter.api_prefix.value },
        #   { name = "AWS_REGION", value = data.aws_ssm_parameter.region.value },
        #   { name = "AWS_ACCESS_KEY_ID", value = data.aws_ssm_parameter.access_key_id.value },
        #   { name = "AWS_SECRET_ACCESS_KEY", value = data.aws_ssm_parameter.secret_access_key.value },
        #   { name = "ACCESS_SECRET", value = data.aws_ssm_parameter.access_secret.value },
        #   { name = "EMAIL_SECRET", value = data.aws_ssm_parameter.email_secret.value },
        #   { name = "FORGET_SECRET", value = data.aws_ssm_parameter.forget_secret.value },
        #   { name = "LIMITER", value = data.aws_ssm_parameter.limiter.value },
        #   { name = "MAIN_DOMAIN", value = data.aws_ssm_parameter.main_domain.value },
        #   { name = "PUBLIC_CONNECTION", value = data.aws_ssm_parameter.public_connection.value },
        #   { name = "TENANTS_CONNECTION", value = data.aws_ssm_parameter.tenants_connection.value },
        #   { name = "STRIPE_PRIVATE_KEY", value = data.aws_ssm_parameter.stripe_private_key.value },
        #   { name = "STRIPE_WEBHOOK_SECRET", value = data.aws_ssm_parameter.stripe_webhook_secret.value },
        # ],
        "logConfiguration" : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-group" : "${var.cloudwatch_group_name}",
            "awslogs-region" : "${var.region}",
            "awslogs-stream-prefix" : "ecs"
          }
        }
      }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 3072
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.task_role_arn
  tags = {
    Name = "${var.projectName}-task_definition-${var.environment}"
  }
}
