output "endpoint" {
  value = "${aws_eks_cluster.eks_cluster.endpoint}"
}

output "kubeconfig_certificate_authority_data" {
  value = "${aws_eks_cluster.eks_cluster.certificate_authority.0.data}"
}

output "eks_auto_scaling_group_name" {
  value = "${aws_eks_node_group.eks_cluster_node_group.resources.0.autoscaling_groups.0.name}"
}
