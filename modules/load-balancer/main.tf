# Create application load balancer
resource "aws_lb" "alb" {
  name                       = "techscrum-lb-${var.environment}"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.alb_security_group_id]
  subnets                    = [for subnet in var.public_subnets_ids : subnet]
  enable_deletion_protection = false

  tags = {
    Name = "${var.projectName}-alb-${var.environment}"
  }
}

# Create target group and attach to load balancer
resource "aws_lb_target_group" "tg" {
  name        = "techscrum-http-alb-tg-${var.environment}"
  target_type = "ip"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    protocol = "HTTP"
    matcher  = "200-399"
    path     = var.health_check_path
    timeout  = 10 # 设置一个小于健康检查间隔的超时时间
    interval = 30 # 可以设置健康检查间隔时间（可选）
  }

  tags = {
    Name = "${var.projectName}-tg-${var.environment}"
  }
}

# Create listener on port 80 wirh redirect action
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Create a listener on port 443 with forward action
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.backend_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
