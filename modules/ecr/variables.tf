variable "aws_ecr_app" {
  type = string
  description = "ECR application name"
}

variable "aws_ecr_repo_name" {
  type = list(string)
  description = "ECR repository names"
}