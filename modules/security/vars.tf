variable "common_tags" {
  description = "Common tags to apply to all resources"
  type = "map"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "env" {
  description = "The name of the environment"
}

variable "project" {
  description = "The name of the project"
}


variable "public_cidr" {
  type = "list"
}

variable "cluster_name" {
  description = "EKS cluster name"
}
