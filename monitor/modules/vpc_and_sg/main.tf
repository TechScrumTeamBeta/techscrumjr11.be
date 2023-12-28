#create vpc for monitor
resource "aws_vpc" "vpc_monitor" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
  tags = {
    Name = "monitor-vpc"
  }
}

#create  aws internet gateway for the vpc
resource "aws_internet_gateway" "monitor-igw" {
  vpc_id = aws_vpc.vpc_monitor.id
  tags = {
    Name = "monitor-igw"
  }
}

#  aws public subnets 
resource "aws_subnet" "monitor-public-subnet" {
  vpc_id                  = aws_vpc.vpc_monitor.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  count                   = length(var.public_subnets)
  map_public_ip_on_launch = true
  tags = {
    Name = "monitor-public-subnet-${count.index + 1}"
  }
}

# aws monitor route table 
resource "aws_route_table" "monitor-rt" {
  vpc_id = aws_vpc.vpc_monitor.id
  tags = {
    Name = "monitor-routing-table"
  }
}

# aws route for public subnets
resource "aws_route" "monitor-route" {
  route_table_id         = aws_route_table.monitor-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.monitor-igw.id
}

# aws monitor public route table association
resource "aws_route_table_association" "monitor-public" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.monitor-public-subnet.*.id, count.index)
  route_table_id = aws_route_table.monitor-rt.id
}


///create a security group for  monitor ec2
resource "aws_security_group" "monitor-sg" {
  name        = "monitor-security-group"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc_monitor.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "monitor"
  }
}
