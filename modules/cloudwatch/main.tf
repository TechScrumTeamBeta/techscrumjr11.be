
resource "aws_cloudwatch_log_group" "log_group_ecs_fargate" {
  name = "ecs_fargate_${var.projectName}_${var.environment}"

  tags = {
    Name = "ecs_fargate_${var.projectName}_${var.environment}"
  }
}

resource "aws_sns_topic" "route53_sns" {
  name = "${var.projectName}-backend-sns"
}

resource "aws_sns_topic_subscription" "user_updates" {
  topic_arn = aws_sns_topic.route53_sns.arn
  protocol  = "email"
  endpoint  = var.sns_email
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
  alarm_actions       = [aws_sns_topic.route53_sns.arn]
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
  alarm_actions       = [aws_sns_topic.route53_sns.arn]
  dimensions = {
    HealthCheckId = aws_route53_health_check.health_check_http.id
  }
}


# http healthcheck
resource "aws_route53_health_check" "health_check_http" {

  fqdn              = var.healthcheck_domain_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/api/v2/healthcheck"
  failure_threshold = "5"
  request_interval  = "30"
  tags = {
    Name = var.http_health_check_name
  }
}





#https healthcheck
resource "aws_route53_health_check" "health_check_https" {
  # provider          = aws.us-east-1
  fqdn              = var.healthcheck_domain_name
  port              = 443
  type              = "HTTPS"
   resource_path     = "/api/v2/healthcheck"
  request_interval  = 30
  failure_threshold = 3
  tags = {
    Name = var.https_health_check_name
  }
}




///create sns  alb的sns
resource "aws_sns_topic" "backend_sns" {
  name = "${var.projectName}-backend-sns"
}

# resource "aws_sns_topic_subscription" "user_updates" {
#   topic_arn = aws_sns_topic.backend_sns.arn
#   protocol  = "email"
#   endpoint  = var.sns_email
# }

///alb alarm   后续修改alb name  从moudle里面拿。.
resource "aws_cloudwatch_metric_alarm" "alb_4xx_alarm" {
  alarm_name          = "alb_4xx_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "SampleCount"
  threshold           = "2"
  alarm_description   = "This metric checks for 4xx errors"
  alarm_actions       = [aws_sns_topic.backend_sns.arn]
    dimensions = {
    LoadBalancer = "${var.alb_arn_suffix}"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_alarm" {
  alarm_name          = "alb_5xx_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "SampleCount"
  threshold           = "2"
  alarm_description   = "This metric checks for 5xx errors"
  alarm_actions       = [aws_sns_topic.backend_sns.arn]
  dimensions = {
    LoadBalancer = "${var.alb_arn_suffix}"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_response_time_alarm" {
  alarm_name          = "alb_response_time_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "0.5"
  alarm_description   = "This metric checks response time"
  alarm_actions       = [aws_sns_topic.backend_sns.arn]
  dimensions = {
    LoadBalancer = "${var.alb_arn_suffix}"
  }
}
#  security hub alert
# enable AWS Security Hub
resource "aws_securityhub_account" "example" {
  
}
# bash cli 查看aws security hub
# aws securityhub disable-security-hub --region ap-southeast-2
# aws securityhub describe-hub --region ap-southeast-2
resource "aws_sns_topic" "critical_security_alerts" {
  name = "critical-security-alerts"
}

# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cwe-custom-actions.html
# 上面的是手动 发送 finding 和insights 到 event to send findings and insight results to EventBridge
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.critical_security_alerts.arn
  protocol  = "email"
   endpoint  = var.sns_email 
}
# EventBridge was formerly known as CloudWatch Events. The functionality is identical.
resource "aws_cloudwatch_event_rule" "critical_security_event" {
  name        = "critical-security-event"
  description = "Capture critical security events from Security Hub"

  event_pattern = jsonencode({
    source      = ["aws.securityhub"],
    detail_type = ["Security Hub Findings - Imported"],
    detail      = {
      findings = {
        Severity = {
          Label = ["CRITICAL"]
        }
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "sns_target" {
  rule = aws_cloudwatch_event_rule.critical_security_event.name
  arn  = aws_sns_topic.critical_security_alerts.arn
}


#ecs-dashboard 
resource "aws_cloudwatch_dashboard" "ecs_dashboard" {
  dashboard_name = "${var.projectName}-ECS-Dashboard"

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
          [ "ECS/ContainerInsights", "CpuUtilized", "ClusterName", "${var.cluster_name}", "ServiceName", "techscrum-${var.environment}" ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "ap-southeast-2",
        "title": "ECS Service - CPU Utilization"
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
          [ "ECS/ContainerInsights", "MemoryUtilized", "ClusterName", "${var.cluster_name}", "ServiceName", "techscrum-${var.environment}" ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "ap-southeast-2",
        "title": "ECS Service - Memory Utilization"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 6,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "ECS/ContainerInsights", "StorageReadBytes", "ClusterName", "${var.cluster_name}", "ServiceName", "techscrum-${var.environment}" ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "ap-southeast-2",
        "title": "ECS Prod Service - Storage Read and Write Bytes"
      }
    },
    {
      "type": "metric",
      "x": 13,
      "y": 6,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "ECS/ContainerInsights", "NetworkRxBytes", "ClusterName", "${var.cluster_name}", "ServiceName", "techscrum-${var.environment}" ]
         
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "ap-southeast-2",
        "title": "ECS prod Service - Network I/O"
      }
    }
  ]
}
EOF
}

# alb_dashboard
resource "aws_cloudwatch_dashboard" "alb_dashboard" {
  dashboard_name = "${var.projectName}-ALB-Dashboard"

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
          [ "AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", "${var.alb_arn_suffix}" ],
          [ ".", "HTTPCode_Target_5XX_Count", ".", "." ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "ap-southeast-2",
        "title": "ALB - HTTP 4xx and 5xx Errors"
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
          [ "AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "${var.alb_arn_suffix}" ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "ap-southeast-2",
        "title": "ALB - Response Time"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 6,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${var.alb_arn_suffix}" ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "ap-southeast-2",
        "title": "ALB - Request Count"
      }
    },
    {
      "type": "metric",
      "x": 13,
      "y": 6,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/ApplicationELB", "ActiveConnectionCount", "LoadBalancer", "${var.alb_arn_suffix}" ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "ap-southeast-2",
        "title": "ALB - Active Connection Count"
      }
    }
  ]
}
EOF
}