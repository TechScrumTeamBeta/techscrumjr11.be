data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
data "aws_ssm_parameters_by_path" "config_params" {
  path = "/techscrum/"
}

# Generates ecs task execution role policy in json format 
data "aws_iam_policy_document" "ecs_tasks_execution_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}



# 上面这个这个角色是 ECS 服务本身使用的，主要用于任务执行所需的操作，如拉取容器镜像和存储日志。
# ecs taks exeecule- ecs agent   执行 是agent 执行
# thinks what does the ecs agent need to do on my behalf ,pull image from ecr. insure have log to  cloudwatch logs


#


# Create an ecs task execution role
resource "aws_iam_role" "ecs_tasks_execution_role" {
  name               = "${var.projectName}-${var.environment}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role_policy.json
}

# Attach ecs task execution policy to the iam role
resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  role       = aws_iam_role.ecs_tasks_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#  ECS Task Role:
# 目的: 这个角色是为了授权 ECS 任务本身。它允许任务中的应用程序与 AWS 服务进行交互
#容器需要访问 AWS S3 存储桶中的数据或写入 AWS DynamoDB 表
# ecs task role  -- your code  代码应用程序 需要查看
# any api calls your code itself need to make 
# connect to s3  bucket dynomon DB talbe 
# 两种用法，一种是  of Using Data Source for Assume Role Policy，一种是 jasonencode syntax
# 接下来是 ecs task role
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.projectName}-${var.environment}_ecs_task_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_policy" "ssm_app_policy" {
  name        = "${var.environment}-SSMAppPolicy-leo"
  description = "Policy for SSM parameters under /techscrum/"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = "ssm:GetParameter",
      Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/techscrum/*",
      Effect   = "Allow"
    }]
  })
}
# Attach aws secret policy to ecs execution role
resource "aws_iam_role_policy_attachment" "aws_ssm_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ssm_app_policy.arn
}



