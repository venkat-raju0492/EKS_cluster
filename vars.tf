variable "env" {
  description = "The name of the environment"
}

variable "project" {
  description = "The name of the project"
}

variable "region" {
  description = "AWS region"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type = "list"
  description = "List of private subnets"
}

variable "public_subnet_ids" {
  type = "list"
  description = "List of public subnets"
}

variable "public_cidr" {
  type = "list"
  description = "CIDR for the Levi's public network"
}

variable "asg_ec2_desired_count" {
  description = "Autoscaling Group desired count"
  default     = "2"
}

variable "asg_ec2_max_count" {
  description = "Autoscaling max count"
  default     = "10"
}

variable "asg_ec2_min_count" {
  description = "Autoscaling service min count"
  default     = "1"
}

variable "key_pair" {
  description = "key pair"
}

variable "bastion_host_sg_id" {
  description = "bastion host security group id"
}

variable "asg_instance_type" {
  default     = "t2.medium"
  description = "AWS instance type to use"
}

variable "ec2_volume_size" {
  description = "EC2 Volume size"
  default = 40
}

variable "ec2_volume_type" {
  description = "EC2 Volume type"
  default = "gp2"
}

variable "endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  default = false
}

variable "endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  default = true
}




