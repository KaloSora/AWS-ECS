variable "aws_account_id" {
  type = string
  description = "AWS account ID"
}


variable "aws_region" {
  type = string
  description = "AWS region"
}

variable "aws_vpc_id" {
  type = string
  description = "AWS VPC ID"
}

variable "aws_subnet_id" {
  type = list(string)
  description = "AWS subnet IDs"
}

variable "aws_ecr_app" {
  type = string
  description = "ECR application name"
}

variable "aws_ecr_repo_name" {
  type = list(string)
  description = "ECR repository names"
}

variable "aws_ingress_ip" {
  type = list(string)
  description = "Ingress IP addresses"
}

variable "aws_ecr_tag" {
  type = string
  description = "ECR image tag"
}

variable "aws_ecs_cluster_name" {
  type = string
  description = "ECS cluster name"
}

variable "aws_ecs_container_port" {
  type = number
  description = "ECS container port"
}

variable "aws_ecs_host_port" {
  type = number
  description = "ECS host port"
}

variable "aws_ecs_fargate_cpu" {
  type = number
  description = "ECS Fargate CPU (1024 unit = 1 vCPU)"
  default = 256
}

variable "aws_ecs_fargate_memory" {
  type = number
  description = "ECS Fargate memory"
  default = 512
}

variable "aws_ecs_desired_task_count" {
  type = number
  description = "ECS desired task count"
  default = 1
}

variable "aws_hosted_zone_name" {
  type = string
  description = "AWS route53 hosted zone name"
}