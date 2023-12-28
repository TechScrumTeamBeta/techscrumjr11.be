data "aws_route53_zone" "route53" {
  name = var.hosted_zone_name
}

data "aws_lb" "eks" {
  name = "techscrum-prod-ingress-alb"
}

resource "aws_route53_record" "eks-api" {
  zone_id = data.aws_route53_zone.route53.zone_id
  name    = "eks-api.${data.aws_route53_zone.route53.name}"
  type    = "A"

  alias {
    name                   = data.aws_lb.eks.dns_name
    zone_id                = data.aws_lb.eks.zone_id
    evaluate_target_health = true
  }

  set_identifier = "PRIMARY"
  failover_routing_policy {
    type = "PRIMARY"
  }

  health_check_id = aws_route53_health_check.techscrum_eks.id
}

resource "aws_route53_health_check" "techscrum_eks" {
  fqdn              = data.aws_lb.eks.dns_name
  port              = "80"
  type              = "HTTP"
  resource_path     = "/api/v1/health_check"
  failure_threshold = "3"
  request_interval  = "30"

  tags = {
    Name = "techscrum-eksRoute53-healthCheck"
  }
}
