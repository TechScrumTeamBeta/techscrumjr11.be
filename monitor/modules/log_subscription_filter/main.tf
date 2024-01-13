data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

//create log subscription_filter lambda
resource "aws_lambda_function" "log_lambda" {
  function_name = "LogProcessor"
  role          = var.role_arn
  handler       = "index.handler"

  source_code_hash = filebase64sha256("index.zip")
  filename         = "index.zip"

  runtime = "nodejs16.x"

  environment {
    variables = {
      OPENSEARCH_ENDPOINT = var.OPENSEARCH_ENDPOINT
    }
  }
}

//set lambda access to log filter
resource "aws_lambda_permission" "allow_cloudwatch_performance_uat" {
  statement_id  = "AllowExecutionFromCloudWatchPerformanceUat"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_lambda.function_name
  principal     = "logs.${data.aws_region.current.name}.amazonaws.com"

  source_arn = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/ecs/containerinsights/${var.app_name}-ecs-cluster-${var.app_environment_uat}/performance:*"
}

resource "aws_lambda_permission" "allow_cloudwatch_performance_prod" {
  statement_id  = "AllowExecutionFromCloudWatchPerformanceProd"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_lambda.function_name
  principal     = "logs.${data.aws_region.current.name}.amazonaws.com"

  source_arn = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/ecs/containerinsights/${var.app_name}-ecs-cluster-${var.app_environment_prod}/performance:*"
}

resource "aws_lambda_permission" "allow_cloudwatch_service_prod" {
  statement_id  = "AllowExecutionFromCloudWatchServiceProd"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_lambda.function_name
  principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
  source_arn    = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${var.app_name}-log-group-${var.app_environment_prod}:*"
}
resource "aws_lambda_permission" "allow_cloudwatch_service_uat" {
  statement_id  = "AllowExecutionFromCloudWatchServiceUat"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_lambda.function_name
  principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
  source_arn    = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${var.app_name}-log-group-${var.app_environment_uat}:*"
}

//create the log subscription
resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_log_filter_performance_uat" {
  name            = "cloudwatch_to_es_filter_uat"
  log_group_name  = "/aws/ecs/containerinsights/${var.app_name}-ecs-cluster-${var.app_environment_uat}/performance"
  filter_pattern  = "" // Add your filter pattern here
  destination_arn = aws_lambda_function.log_lambda.arn
  depends_on      = [aws_lambda_permission.allow_cloudwatch_performance_uat]
}
resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_log_filter_performance_prod" {
  name            = "cloudwatch_to_es_filter_performance_prod"
  log_group_name  = "/aws/ecs/containerinsights/${var.app_name}-ecs-cluster-${var.app_environment_prod}/performance"
  filter_pattern  = "" // Add your filter pattern here
  destination_arn = aws_lambda_function.log_lambda.arn
  depends_on      = [aws_lambda_permission.allow_cloudwatch_performance_prod]
}
resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_log_filter_service_prod" {
  name            = "cloudwatch_to_es_filter_service_prod"
  log_group_name  = "${var.app_name}-log-group-${var.app_environment_prod}"
  filter_pattern  = "" // Add your filter pattern here
  destination_arn = aws_lambda_function.log_lambda.arn
  depends_on      = [aws_lambda_permission.allow_cloudwatch_service_prod]
}
resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_log_filter_service_uat" {
  name            = "cloudwatch_to_es_filter_service_uat"
  log_group_name  = "${var.app_name}-log-group-${var.app_environment_uat}"
  filter_pattern  = "" // Add your filter pattern here
  destination_arn = aws_lambda_function.log_lambda.arn
  depends_on      = [aws_lambda_permission.allow_cloudwatch_service_uat]
}
