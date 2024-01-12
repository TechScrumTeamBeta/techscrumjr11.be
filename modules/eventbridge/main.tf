resource "aws_cloudwatch_event_rule" "lambda_event_rule" {
  name = "lambda-event-rule"
  description = var.description
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  arn = var.lambda_name_arn 
  rule = aws_cloudwatch_event_rule.lambda_event_rule.name
}

resource "aws_lambda_permission" "call_lambda" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = var.lambda_name_arn
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.lambda_event_rule.arn
}