data "aws_iam_policy_document" "logstream-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "cust_logstream_access" {
  statement {
    actions   = ["logs:*", "s3:*", "dynamodb:*", "cloudwatch:*", "sns:*", "lambda:*", "secretsmanager:*", "ds:*", "ec2:*"]
    effect    = "Allow"
    resources = ["*"]
  }
  # add another statement to allow lambda to access opensearch
  statement {
    actions   = ["es:*"]
    effect    = "Allow"
    resources = ["arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/*"]
  }
  # add another statement to allow lambda to perform /bulk action on the opensearch domain
  statement {
    actions   = ["es:ESHttp*"]
    effect    = "Allow"
    resources = ["arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/*"]
  }
  statement {
    actions   = ["es:ESHttpPost", "es:ESHttpPut"]
    effect    = "Allow"
    resources = ["arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/*"]
  }

  statement {
    actions   = ["es:ESHttpDelete"]
    effect    = "Allow"
    resources = ["arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/*"]
  }

}

resource "aws_iam_role" "custlogstreamrole" {
  name               = "custlogstreamrole"
  assume_role_policy = data.aws_iam_policy_document.logstream-assume-role-policy.json
  inline_policy {
    name   = "policy-867530231"
    policy = data.aws_iam_policy_document.cust_logstream_access.json
  }
}