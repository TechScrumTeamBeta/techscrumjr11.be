
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

variable "input_s3_bucket" {
  description = "The regional domain name of the S3 bucket"
}

variable "input_acm_certificate_arn" {
  description = "The ARN of the ACM certificate"
  type        = string
}

variable "oai-iam" {
  
}
variable "asterisk_domain_name" {
  type        = string
  description = "The domain name to use"
  default     = "*.tecscrum.com"
}