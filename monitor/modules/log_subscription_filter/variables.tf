variable "role_arn" {
  type        = string
  description = "arn of the lambda role"
}


variable "OPENSEARCH_ENDPOINT" {
  type        = string
  description = "OPENSEARCH ENDPOINT"
}

variable "app_name" {
  type        = string
  description = "Application Name"
}

variable "app_environment_uat" {
  type        = string
  description = "Application Environment"
}

variable "app_environment_prod" {
  type        = string
  description = "Application Environment"
}