output "eks_cluster_id" {
    value = aws_eks_cluster.eks.id
}

output "eks_node_group" {
    value = aws_eks_node_group.nodes
}

output "cluster_url" {
    value = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}