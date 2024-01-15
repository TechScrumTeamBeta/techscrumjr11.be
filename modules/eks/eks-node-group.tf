resource "aws_eks_node_group" "nodes" {

  cluster_name = aws_eks_cluster.eks.name
  node_group_name = "${var.projectName}-node"
  node_role_arn = var.nodes_arn
  subnet_ids = var.public_subnets_ids
    # subnet_ids = var.private_subnets_ids
  scaling_config {
    desired_size = 3
    max_size = 5
    min_size = 1
  }

  # Valid values: AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64
  ami_type = "AL2_x86_64"

  # Valid values: ON_DEMAND, SPOT
  capacity_type = "ON_DEMAND"

  disk_size = 20

  # Force version update if existing pods are unable to be drained due to a pod disruption budget issue.
  force_update_version = false

  # List of instance types associated with the EKS Node Group
  instance_types = [var.instance_types]


  # Desired max percentage of unavailable worker nodes during node group update.
  update_config {
    max_unavailable = 1    
    #max_unavailable_percentage = 50  
  }

  labels = {
    Name = "${var.projectName}-${var.environment}"
  }

  version = var.cluster_version
  
  depends_on = [
    var.eks_node_policy,
    var.eks_cni_policy_attachment,
    var.eks_container_readonly_attachment
  ]
}