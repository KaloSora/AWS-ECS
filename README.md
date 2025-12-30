
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

3. Build nginx image
```
cd ./Docker/
docker build -t ecr-nginx -f Dockerfile .
docker images | grep ecr-nginx

# Test docker image
docker run -d -p 8080:80 --name ecr-nginx-container ecr-nginx
http://localhost:8080
```

4. Push to ECR
```
AWS_ACCOUNT_ID="your_account_id"
REGION="your_region"
REPO_NAME="your_repository"
IMAGE_NAME="your_image_name"
IMAGE_TAG="latest"

# Login to ECR
aws ecr get-login-password --region $REGION | \
docker login --username AWS --password-stdin \
$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Tag local image
docker tag $IMAGE_NAME:$IMAGE_TAG \
$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:$IMAGE_NAME-$IMAGE_TAG

# Push to ECR
docker push \
$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:$IMAGE_NAME-$IMAGE_TAG

# Health check
aws ecr describe-images \
    --repository-name $REPO_NAME \
    --region $REGION
```