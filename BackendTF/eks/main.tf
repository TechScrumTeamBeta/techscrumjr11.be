#Create network
module "networking" {
  source                  = "../../modules/networking"
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

# Create EKS cluster role, work node role and attach necessary policy
module "iam_role_eks" {
  source      = "../../modules/IAM-EKS"
  projectName = var.projectName
  environment = var.environment
}

#Create eks cluster and nodes group
module "eks" {
  source                            = "../../modules/eks"
  projectName                       = var.projectName
  environment                       = var.environment
  public_subnets_ids                = var.public_subnet_cidrs
  private_subnets_ids                = var.private_subnet_cidrs
  # public_subnets_ids                = module.networking.public_subnets_ids
  # private_subnets_ids                = module.networking.private_subnets_ids
  instance_types                    = var.instance_types
  cluster_version                   = var.cluster_version
  k8s_cluster_name                  = var.k8s_cluster_name
  eks_cluster_role_arn              = module.iam_role_eks.eks_cluster_role_arn
  nodes_arn                         = module.iam_role_eks.eks_nodes_arn
  eks_node_policy                   = module.iam_role_eks.eks_node_policy
  eks_cni_policy_attachment         = module.iam_role_eks.eks_cni_policy_attachment
  eks_container_readonly_attachment = module.iam_role_eks.eks_container_readonly_attachment
}

module "iam_alb_controller" {
  source      = "../../modules/IAM-alb-controller"
  projectName = var.projectName
  environment = var.environment
  cluster_url = module.eks.cluster_url
}

module "helm" {
  source                                 = "../../modules/helm"
  load_balancer_controller_policy_attach = module.iam_alb_controller.load_balancer_controller_policy_attach
  eks_node_group                         = module.eks.eks_node_group
  eks_cluster_id                         = module.eks.eks_cluster_id
  aws_load_balancer_controller_role_arn  = module.iam_alb_controller.aws_load_balancer_controller_role_arn
}