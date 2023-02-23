output "eks_arn" {
  value       = aws_eks_cluster.eks_control.arn
  description = "ARN of the EKS cluster."
}

output "ca_data" {
  value       = aws_eks_cluster.eks_control.certificate_authority.0.data
  description = "The EKS cluster's certificate authority."
}

output "eks_endpoint" {
  value       = aws_eks_cluster.eks_control.endpoint
  description = "API endpoint of the EKS cluster."
}

output "eks_name" {
  value       = aws_eks_cluster.eks_control.id
  description = "The name of the EKS cluster."
  depends_on  = [aws_eks_addon.vpc_cni] #custom-cni-networking module requires this to be completed before running
}

output "control_plane_role_arn" {
  value       = aws_eks_cluster.eks_control.role_arn
  description = "ARN of the IAM role that provides permissions for the Kubernetes control plane to make calls to AWS API operations on your behalf."
}

output "control_plane_sg_rule_id" {
  value       = aws_security_group_rule.cluster_shared_node_443.id
  description = "ID of the security group of the EKS cluster."
}

output "control_plane_sg_id" {
  value       = aws_eks_cluster.eks_control.vpc_config[0].cluster_security_group_id
  description = "Cluster security group ID for control-plane to data-plane communication"
}

# vim: sw=2 ts=2 et
