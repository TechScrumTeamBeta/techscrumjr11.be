

variable "bucket_name" {
  type        = string
  description = "The name for the S3 bucket"
  default     = "techscrum-frontend-jr10"
}
variable "domain_name" {
  type        = string
  description = "The domain name to use"
  default     = "www.techscrumjr11.com"
}

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
variable "data_transfer_alarm_name" {
  description = "data transfer alarm name"
  type        = string
  default     = "techsrum-data_transfer_alarm"
}
variable "error_rate_alarm_name" {
  description = "error rate alarm"
  type        = string
  default     = "techsrum-error_rate_alarm"
}

variable "dashboard_name" {
  description = "dashboard name"
  type        = string
  default     = "techsrum-fe-dashboard"
}


variable "cloudfront-input" {
  
}