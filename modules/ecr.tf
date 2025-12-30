module "ecr" {
  source = "./ecr"
  aws_ecr_app       = var.aws_ecr_app
  aws_ecr_repo_name = var.aws_ecr_repo_name
}