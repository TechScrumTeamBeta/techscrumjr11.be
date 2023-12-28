resource "aws_iam_policy" "s3policy" {
  policy = file("./s3policy.json")
  name   = "${var.projectName}-${var.lambda_name}-s3policy"
}

resource "aws_iam_role_policy_attachment" "s3policy_attach" {
  role       = var.lambdaRole_name
  policy_arn = aws_iam_policy.s3policy.arn
} 