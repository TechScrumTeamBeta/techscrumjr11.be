output "lambda_name_arn" {
value = aws_lambda_function.func.arn
}
output "lambdaRole_name" {
value = aws_iam_role.lambda.name
}