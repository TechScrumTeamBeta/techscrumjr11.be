resource "aws_eks_cluster" "eks" {
  
  name = "${var.k8s_cluster_name}"

  role_arn = var.eks_cluster_role_arn

  version = var.cluster_version

  vpc_config {

    endpoint_private_access = true

    endpoint_public_access = true

    subnet_ids = var.public_subnets_ids
  }
}