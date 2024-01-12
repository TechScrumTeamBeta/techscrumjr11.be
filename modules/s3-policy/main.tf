# obtain current account ID
data "aws_caller_identity" "current" {}

# generate s3 OAC policy
data "aws_iam_policy_document" "s3_OAC_policy" {
  statement {
    sid = "AllowCloudFrontServicePrincipalReadOnly"

    actions = ["s3:GetObject"]

    principals {
      type = "Service"
      #   identifiers = [aws_cloudfront_origin_access_identity.cloudfront_oia.iam_arn]
      identifiers = ["cloudfront.amazonaws.com"]
    }

    resources = [
      "arn:aws:s3:::${var.S3_webhost_bucket}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${var.cloudfront_distribution_id}"
      ]
    }
  }
}