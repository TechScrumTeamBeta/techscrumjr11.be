variable "environment" {}
variable "cluster_name" {}
variable "ecs_execution_role_arn" {}
variable "task_role_arn" {}
variable "task_definition_arn" {}
variable "target_group_arn" {}
variable "public_subnets_ids" {}
variable "ecs_security_group_id" {}
variable "alb_security_group_id" {}
variable "projectName" {}
variable "cloudwatch_group_name" {}
variable "region" {}
variable "private_subnets_ids" {}
variable "imageURI" {}
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