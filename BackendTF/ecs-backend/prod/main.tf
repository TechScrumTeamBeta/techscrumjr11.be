



# Create network
module "networking" {
  source                  = "../../../modules/networking"
  region                  = var.region
  projectName             = var.projectName
  vpc_cidr                = var.vpc_cidr
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  route_table_cidr_block  = var.route_table_cidr_block
  aws_availabbility_zones = var.aws_availabbility_zones
  environment             = var.environment
  k8s_cluster_name        = var.k8s_cluster_name
}
module "ses" {
  source = "../../../modules/ses"
}




# Create security groups for alb and ecs 
module "security_group" {
  source      = "../../../modules/security-group"
  vpc_id      = module.networking.vpc_id
  projectName = var.projectName
  environment = var.environment
}

# Create alb
module "application_load_balancer" {
  source                  = "../../../modules/load-balancer"
  alb_security_group_id   = module.security_group.alb_security_group_id
  projectName             = var.projectName
  public_subnets_ids      = module.networking.public_subnets_ids
  vpc_id                  = module.networking.vpc_id
  backend_certificate_arn = var.backend_certificate_arn
  environment             = var.environment
  health_check_path       = var.health_check_path
}

# Create ECS execution role
module "iam" {
  source      = "../../../modules/IAM"
  projectName = var.projectName
  environment = var.environment
}

# Create cloudwatch group
module "cloudwatch" {
  source      = "../../../modules/cloudwatch"
  projectName = var.projectName
  environment = var.environment
}

# Creat ECS task definition and ECS service
module "ecs" {
  source                 = "../../../modules/ecs"
  cluster_name           = var.cluster_name
  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
  task_role_arn          = module.iam.ecs_task_role_arn
  task_definition_arn    = module.ecs.task_definition_arn
  target_group_arn       = module.application_load_balancer.target_group_arn
  public_subnets_ids     = module.networking.public_subnets_ids
  private_subnets_ids    = module.networking.private_subnets_ids
  ecs_security_group_id  = module.security_group.ecs_security_group_id
  alb_security_group_id  = module.security_group.alb_security_group_id
  projectName            = var.projectName
  cloudwatch_group_name  = module.cloudwatch.cloudwatch_group_name
  region                 = var.region
  environment            = var.environment
  imageURI               = var.imageURI
  depends_on             = [module.iam]
}

# Create route53
module "route53" {
  source           = "../../../modules/backend-route53"
  alb_dns_name     = module.application_load_balancer.alb_dns_name
  alb_zone_id      = module.application_load_balancer.alb_zone_id
  hosted_zone_name = var.hosted_zone_name
  environment      = var.environment
}
