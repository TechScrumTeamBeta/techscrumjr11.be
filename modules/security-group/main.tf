# Create sg for alb
resource "aws_security_group" "alb-sg" {
  name        = "techscrum-alb-sg"
  description = "Allow http/https traffic inbound on port 80/443"
  vpc_id      = var.vpc_id

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # if ipv6 needed    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #if ipv6 needed     ipv6_cidr_blocks = ["::/0"] 
  }

  ingress {
    description = "http"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #if ipv6 needed     ipv6_cidr_blocks = ["::/0"] 
  }

  ingress {
    description = "http"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #if ipv6 needed     ipv6_cidr_blocks = ["::/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    #if ip v6 needed    ipv6_cidr_blocks = ["::/0"] 
  }

  tags = {
    Name = "${var.projectName}-sg-${var.environment}"
  }
}

# Create sg for ecs
resource "aws_security_group" "ecs-sg" {
  name        = "techscrum-ecs-sg"
  description = "Allow http/https traffic inbound on port 80/443"
  vpc_id      = var.vpc_id

  ingress {
    description     = "https"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
  }

  ingress {
    description     = "http"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
  }

  ingress {
    description     = "http"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
  }

  ingress {
    description     = "http"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
  }

  ingress {
    description = "http"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #if ipv6 needed     ipv6_cidr_blocks = ["::/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    #if ip v6 needed    ipv6_cidr_blocks = ["::/0"] 
  }

  tags = {
    Name = "${var.projectName}-sg-${var.environment}"
  }
}

