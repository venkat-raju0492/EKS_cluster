resource "null_resource" "subnet_tags" {
  count = "${length(var.cluster_nodes_subnet_ids)}"
  provisioner "local-exec" {
    command = "aws --region ${var.region} ec2 create-tags --resources ${var.cluster_nodes_subnet_ids[count.index]} --tags Key=kubernetes.io/cluster/${var.cluster_name},Value=shared"
  }

  provisioner "local-exec" {
    when = "destroy"
    command = "aws --region ${var.region} ec2 delete-tags --resources ${var.cluster_nodes_subnet_ids[count.index]} --tags Key=kubernetes.io/cluster/${var.cluster_name},Value=shared"
  }
}

resource "aws_eks_cluster" "eks_cluster" {
  name            = "${var.cluster_name}"
  role_arn        = "${var.eks_cluster_role_arn}"
  enabled_cluster_log_types = "${var.enabled_cluster_log_types}"

  vpc_config {
    endpoint_private_access = "${var.endpoint_private_access}"
    endpoint_public_access  = "${var.endpoint_public_access}"
    security_group_ids = ["${var.eks_cluster_sg_id}"]
    subnet_ids         = "${var.cluster_subnet_ids}"
  }

  depends_on = [
    "aws_cloudwatch_log_group.eks_logging"
  ]

  tags = "${merge(var.common_tags, map(
    "Name", "${var.cluster_name}"
  ))}"
}

resource "aws_eks_node_group" "eks_cluster_node_group" {
  cluster_name    = "${aws_eks_cluster.eks_cluster.name}"
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = "${var.eks_cluster_nodes_role_arn}"
  subnet_ids      = "${var.cluster_nodes_subnet_ids}"

  scaling_config {
    desired_size = "${var.nodes_desired_count}"
    max_size     = "${var.nodes_max_count}"
    min_size     = "${var.nodes_min_count}"
  }

  remote_access {
    ec2_ssh_key = "${var.node_key_pair}"
    source_security_group_ids = "${var.eks_cluster_nodes_remote_access_sg_ids}"
  }

  disk_size = "${var.node_disk_size}"
  instance_types = "${var.nodes_instance_types}"

  tags = "${merge(var.common_tags, map(
    "Name", "${var.cluster_name}-node-group"
  ))}"

  depends_on = [
    "null_resource.subnet_tags"
  ]
}

resource "aws_cloudwatch_log_group" "eks_logging" {
  name                      = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days         = "${var.eks_cloudwatch_log_retentions}"
}

