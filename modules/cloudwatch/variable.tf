variable "projectName" {}
variable "environment" {}


variable "sns_email" {
  description = "sns email"
  type        = string
}




variable "alb_arn_suffix" {
  description = "alb arn suffix"
}

variable "cluster_name" {}

variable "http_health_check_name" {
  description = "http health check name"
  type        = string
  default     = "techsrum-http-health-check"
}

variable "https_health_check_name" {
  description = "https health check name"
  type        = string
  default     = "techsrum-https-health-check"
}

variable "http_health_check_alarm_name" {
  description = "http health check alarm name"
  type        = string
  default     = "techsrum-http_health_check_alarm"
}

variable "https_health_check_alarm_name" {
  description = "https health check alarm name"
  type        = string
  default     = "techsrum-https_health_check_alarm"
}

variable "healthcheck_domain_name" {
  
}