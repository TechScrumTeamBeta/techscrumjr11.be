
resource "aws_cloudwatch_dashboard" "techscrum-cloudwatch-dashboard" {
  dashboard_name = var.dashboard_name
  
   dashboard_body = <<EOF
{
"widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/Route53",
            "HealthCheckStatus",
            "HealthCheckId",
            "${aws_route53_health_check.health_check_http.id}"
          ],
          [
            "AWS/Route53",
            "HealthCheckStatus",
            "HealthCheckId",
            "${aws_route53_health_check.health_check_https.id}"
          ]
        ],
        "period": 300,
        "stat": "SampleCount",
        "region": "us-east-1",
        "title": "HTTP & HTTPS Health Check Status",
        "view": "timeSeries",
        "stacked": false,
        "yAxis": {
          "left": {
            "min": 0,
            "max": 1
          },
          "right": {
            "showUnits": false
          }
        },
        "annotations": {
          "horizontal": [
            {
              "color": "#ff6961",
              "label": "Unhealthy threshold",
              "value": 0
            }
          ]
        }
      }
    },
    {
      "type": "metric",
      "x": 13,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/CloudFront",
            "5xxErrorRate",
            "Region",
            "Global",
            "DistributionId",
            "${var.cloudfront-input.id}"
          ],
          [
            "AWS/CloudFront",
            "4xxErrorRate",
            "Region",
            "Global",
            "DistributionId",
            "${var.cloudfront-input.id}"
          ]
        ],
        "region": "us-east-1",
        "title": "CloudFront Error Rates - 4xx & 5xx Errors",
        "view": "timeSeries",
        "stacked": false
      }
    }
]

}
EOF
}



///create sns
resource "aws_sns_topic" "my_sns" {
 
  name     = "my_sns"
}

resource "aws_sns_topic_subscription" "user_updates" {
 
  topic_arn = aws_sns_topic.my_sns.arn
  protocol  = "email"
  endpoint  = "fisherinaus@gmail.com"
}



///create alarm and sns
resource "aws_cloudwatch_metric_alarm" "data_transfer_alarm" {

  alarm_name          = var.data_transfer_alarm_name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "BytesDownloaded"
  namespace           = "AWS/CloudFront"
  period              = "300"
  statistic           = "Average"
  threshold           = "10000000000" // Set this to the desired threshold for data transfer in bytes
  alarm_description   = "This metric checks the amount of data transferred from your CloudFront distribution"
  alarm_actions       = [aws_sns_topic.my_sns.arn]
  dimensions = {
    Region         = "Global"
    DistributionId = var.cloudfront-input.id
  }
}

resource "aws_cloudwatch_metric_alarm" "error_rate_alarm" {

  alarm_name          = var.error_rate_alarm_name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = "300"
  statistic           = "Average"
  threshold           = "5" // Set this to the desired threshold for error rate in percentage
  alarm_description   = "This metric checks the error rate for your CloudFront distribution"
  alarm_actions       = [aws_sns_topic.my_sns.arn]
  dimensions = {
    Region         = "Global"
    DistributionId = var.cloudfront-input.id
  }
}




resource "aws_cloudwatch_metric_alarm" "https_health_check_alarm" {
 
  alarm_name          = var.https_health_check_alarm_name
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  alarm_description   = "This metric checks the health status of the endpoint's https"
  alarm_actions       = [aws_sns_topic.my_sns.arn]
  dimensions = {
    HealthCheckId = aws_route53_health_check.health_check_https.id
  }
}



resource "aws_cloudwatch_metric_alarm" "http_health_check_alarm" {
 
  alarm_name          = var.http_health_check_alarm_name
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  alarm_description   = "This metric checks the health status of the endpoint's http"
  alarm_actions       = [aws_sns_topic.my_sns.arn]
  dimensions = {
    HealthCheckId = aws_route53_health_check.health_check_http.id
  }
}


# http healthcheck
resource "aws_route53_health_check" "health_check_http" {
  # provider          = aws.us-east-1
  fqdn              = var.domain_name
  port              = 80
  type              = "HTTP"
  request_interval  = 30
  failure_threshold = 3
  tags = {
    Name = var.http_health_check_name
  }
}



#https healthcheck
resource "aws_route53_health_check" "health_check_https" {
  # provider          = aws.us-east-1
  fqdn              = var.domain_name
  port              = 443
  type              = "HTTPS"
  request_interval  = 30
  failure_threshold = 3
  tags = {
    Name = var.https_health_check_name
  }
}


