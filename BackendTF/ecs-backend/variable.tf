variable "region" {}

variable "projectName" {}

variable "environment" {}

variable "vpc_cidr" {}

variable "public_subnet_cidrs" {}

variable "private_subnet_cidrs" {}

variable "route_table_cidr_block" {}

variable "aws_availabbility_zones" {}

variable "cluster_name" {}

variable "backend_certificate_arn" {}

variable "health_check_path" {}

variable "hosted_zone_name" {}

variable "imageURI" {}
variable "k8s_cluster_name" {
  
}

variable "sns_email" {
  description = "sns email"
  type        = string
}
variable "task_min_count" {
  description = "min count of tasks"
  type        = number
  default     = 2
}

variable "task_max_count" {
  description = "min count of tasks"
  type        = number
  default     = 4
}

variable "healthcheck_domain_name" {
    description = "healtcheck of backend"
}