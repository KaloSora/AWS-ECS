## To store all variables related to AWS Docker setup
#########

aws_account_id      = "795359014551"
aws_region          = "ap-northeast-1"
aws_vpc_id         = "vpc-049e93d6ffc91a83d"
aws_subnet_id      = ["subnet-00628a1a4aa10b3c6", "subnet-0e2b066f1cdf66ef7"]
aws_ingress_ip     = ["0.0.0.0/8"] # Provide your ip

## ECR variables
aws_ecr_app = "my-app"
aws_ecr_repo_name   = ["test", "prod"]

## ECS variables
aws_ecr_tag = "ecr-nginx-latest"
aws_ecs_cluster_name = "my-ecs-cluster"
aws_ecs_container_port = 80
aws_ecs_host_port = 80
aws_ecs_fargate_cpu = 256
aws_ecs_fargate_memory = 512
aws_ecs_desired_task_count = 2

## Route53 variables
aws_hosted_zone_name = "ecs.kalosora.work.com"