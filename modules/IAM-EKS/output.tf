output  "eks_cluster_role_arn" {
  value   = aws_iam_role.eks_cluster_role.arn
}
output  "eks_nodes_arn" {
  value = aws_iam_role.nodes.arn
}
output "eks_node_policy"{
  value = aws_iam_role_policy_attachment.amazon_eks_worker_node_policy
}
output "eks_cni_policy_attachment"{
  value = aws_iam_role_policy_attachment.amazon_eks_cni_policy_general
}
output "eks_container_readonly_attachment"{
  value =  aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only
}