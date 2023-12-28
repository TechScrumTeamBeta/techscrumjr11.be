variable "vpc_cidr_block" {
  type        = string
  description = "cidr block  of vpc"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnets"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}
