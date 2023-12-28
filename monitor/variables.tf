variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "domain_name" {
  description = "domain name of the opensearch cluster"
  type        = string
  default     = "logs-opensearch"
}

variable "masteruser_name" {
  description = "masteruser name"
  type        = string
  default     = "admin"
}

variable "masteruser_password" {
  description = "masteruser password"
  type        = string
  default     = "Admin10$"
}

variable "app_name" {
  type        = string
  description = "Application Name"
  default     = "techscrum"
}

variable "app_environment_uat" {
  type        = string
  description = "Application Environment"
  default     = "uat"
}

variable "app_environment_prod" {
  type        = string
  description = "Application Environment"
  default     = "prod"
}

variable "vpc_cidr_block" {
  type        = string
  description = "cidr block  of  vpc"
  default     = "13.0.0.0/16"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of  public subnets"
  default     = ["13.0.0.0/20", "13.0.16.0/20"]
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
  default     = ["ap-southeast-2a", "ap-southeast-2b"]
}