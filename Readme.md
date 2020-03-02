#terraform file for EKS cluster
#Includes security groups and IAM roles and policies.


#provide the detail in tfvars file with project name, vpc ID, Region, private and pulic subnet IDs, and instance type 


#how to apply
#terraform init
terraform init -backen-config="bucket=<S3 bucket name in the same region>" \
            -backend-config="key=<S3 key>" \
            -backend-config="region=<s3 bucket region>" \
            -backend=true \
            -force-copy \
            -get=true \
            -input=false

#terraform plan with plan file
terraform plan -var-file=dev.tfvars -out .terraform/latest-plan

#terraform apply
terraform apply --input=false .terraform/latest-plan

#provisions eks cluster in desired region with private access 
