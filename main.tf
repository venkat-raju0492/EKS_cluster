terraform {
  backend "s3" {}
}

provider "aws" {
  region = "${var.region}"
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Project = "${var.project}"
    Environment = "${var.env}"
    CreatedBy = "Terraform"
  }

  cluster_name = "${var.project}-eks-${var.env}"
}

data "aws_caller_identity" "current" {}

module "Security" {
  source = "./modules/security"
  cluster_name = "${local.cluster_name}"
  env = "${var.env}"
  vpc_id = "${var.vpc_id}"
  public_cidr = "${var.public_cidr}"
  project = "${var.project}"
  common_tags = "${local.common_tags}"
}

module "EKS" {
  source = "./modules/eks"
  region = "${var.region}"
  cluster_name = "${local.cluster_name}"
  cluster_subnet_ids = "${var.public_subnet_ids}"
  eks_cluster_sg_id = "${module.Security.eks_cluster_sg_id}"
  eks_cluster_role_arn = "${module.Security.eks_cluster_role_arn}"
  eks_cluster_nodes_role_arn = "${module.Security.eks_cluster_nodes_role_arn}"
  eks_cluster_nodes_remote_access_sg_ids = ["${var.bastion_host_sg_id}"]
  cluster_nodes_subnet_ids = "${var.private_subnet_ids}"
  nodes_min_count = "${var.asg_ec2_min_count}"
  nodes_max_count = "${var.asg_ec2_max_count}"
  nodes_desired_count = "${var.asg_ec2_desired_count}"
  nodes_instance_types = ["${var.asg_instance_type}"]
  node_disk_size = "${var.ec2_volume_size}"
  node_key_pair = "${var.key_pair}"
  endpoint_private_access = "${var.endpoint_private_access}"
  endpoint_public_access = "${var.endpoint_public_access}"
  common_tags = "${local.common_tags}"
}


