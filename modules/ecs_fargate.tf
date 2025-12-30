module "ecs_fargate" {
  source = "./ecs_fargate"
  app = var.aws_ecr_app
  aws_region = var.aws_region
  cluster_name = var.aws_ecs_cluster_name
  fargate_cpu = var.aws_ecs_fargate_cpu
  fargate_memory = var.aws_ecs_fargate_memory
  desired_count = var.aws_ecs_desired_task_count
  container_port = var.aws_ecs_container_port
  host_port = var.aws_ecs_host_port
  ecr_repo_name = var.aws_ecr_repo_name[0]
  aws_ecr_tag = var.aws_ecr_tag
  aws_ingress_ip = var.aws_ingress_ip
  aws_vpc_id = var.aws_vpc_id
  aws_subnet_id = var.aws_subnet_id
  aws_hosted_zone_name = var.aws_hosted_zone_name
}