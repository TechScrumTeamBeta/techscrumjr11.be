# Create vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags      = {
    Name    = "${var.projectName}-${var.environment}"
  }
}

# Create public subnets in azs
resource "aws_subnet" "public_subnet" {
  count      = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone       = var.aws_availabbility_zones[count.index]
  map_public_ip_on_launch = true

  tags      = {
    Name    = "${var.projectName}_public_subnet"
    "kubernetes.io/cluster/${var.k8s_cluster_name}" = "owned"
    "kubernetes.io/role/elb"    = "1"
  }
}

# Create private subnets in azs
resource "aws_subnet" "private_subnet" {
  count      = var.environment == "prod" ? 1 : 0
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone       = var.aws_availabbility_zones[count.index]
  map_public_ip_on_launch = false

  tags       = {
    Name     = "${var.projectName}_private_subnet"
    "kubernetes.io/cluster/${var.k8s_cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Create internet gateway and attach it to vpc
resource "aws_internet_gateway" "igw" {
  vpc_id    = aws_vpc.vpc.id

  tags      = {
    Name    = "${var.projectName}_igw-${var.environment}"
  }
}

# Creat eip for NAT
resource "aws_eip" "nat" {
  count     = var.environment == "prod" ? 1 : 0
  # vpc      = true
domain   = "vpc" 
  tags     = {
    Name   ="${var.projectName}_eip"
  }
}

# Creat nat gateway
resource "aws_nat_gateway" "nat" {
  count     = var.environment == "prod" ? 1 : 0
  allocation_id = aws_eip.nat[count.index]
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "${var.projectName}_NAT-${var.environment}"
  }

   depends_on = [aws_internet_gateway.igw]
}

# Create public route table 
resource "aws_route_table" "public_route_table" {
  vpc_id       = aws_vpc.vpc.id

  route {
    cidr_block = var.route_table_cidr_block
    gateway_id = aws_internet_gateway.igw.id
  }

  tags       = {
    Name     = "${var.projectName}_public_route_table-${var.environment}" 
  }
}

# Associate public subnets to public route table
resource "aws_route_table_association" "public_subnet_route_table_association" {
  count               = length(var.public_subnet_cidrs)
  subnet_id           = element(aws_subnet.public_subnet.*.id,count.index)
  route_table_id      = aws_route_table.public_route_table.id
}

# Create private route table 
resource "aws_route_table" "private_route_table" {
  count     = var.environment== "prod" ? 1 : 0
  vpc_id       = aws_vpc.vpc.id

  route {
    cidr_block = var.route_table_cidr_block
    gateway_id = aws_nat_gateway.nat[count.index]
  }

  tags       = {
    Name     = "${var.projectName}_private_route_table-${var.environment}"
  }
}

# Associate private subnets to private route table
resource "aws_route_table_association" "private_subnet_route_table_association" {
  count               = var.environment == "prod" ? length(var.private_subnet_cidrs) : 0
  subnet_id           = element(aws_subnet.private_subnet.*.id,count.index)
  route_table_id      = aws_route_table.private_route_table[count.index]
}