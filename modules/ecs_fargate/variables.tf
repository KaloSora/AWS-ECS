variable "cluster_name" {
  type = string
  description = "ECS cluster name"
}

variable "app" {
  type = string
  description = "ECS application name"
}

variable "fargate_cpu" {
  type = number
  description = "ECS Fargate CPU"
}

variable "fargate_memory" {
  type = number
  description = "ECS Fargate Memory"
}

variable "container_port" {
  type = number
  description = "ECS container port"
}

variable "host_port" {
    type = number
    description = "ECS host port"
}

variable "aws_region" {
    type = string
    description = "AWS region"
}

variable "ecr_repo_name" {
  type = string
  description = "ECR repository name"
}

variable "aws_ecr_tag" {
  type = string
  description = "ECR image tag"
}

variable "aws_ingress_ip" {
  type = list(string)
  description = "Ingress IP addresses"
}

variable "aws_vpc_id" {
  type = string
  description = "AWS VPC ID"
}

variable "aws_subnet_id" {
  type = list(string)
  description = "AWS subnet IDs"
}

variable "desired_count" {
  type = number
  description = "ECS desire count"
}

variable "aws_hosted_zone_name" {
  type = string
  description = "AWS route53 hosted zone name"
}