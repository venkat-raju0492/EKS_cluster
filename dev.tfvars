# Environment specific keys
env = "dev"
vpc_id = "<VPC_ID>"
private_subnet_ids = ["PRIVATE_SUBNET_IDS"]
public_subnet_ids = ["PUBLIC_SUBNET_IDS"]
key_pair = "<KEY_PAIR>"
bastion_host_sg_id = "<BASTION_SG_ID>"

region = "<REGION>"
project = "<PROJECT_NAME>"

public_cidr = ["0.0.0.0/0"]

ec2_volume_size=20
ec2_volume_type="gp2"

asg_instance_type = "<INSTANCE_TYPE>"
asg_ec2_max_count = 10
asg_ec2_min_count = 8
asg_ec2_desired_count = 8

endpoint_private_access = true
endpoint_public_access = false

