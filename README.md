
# Purpose
This repository mainly use terraform to create AWS ECR and ECS.

# Usage
1. Terraform init
```
cd ./modules/
terraform init -backend-config="bucket=795359014551-terraform-state"
```

2. Create ECR repository
```
terraform apply -target=module.ecr -var-file="aws-ecs.tfvars"
```