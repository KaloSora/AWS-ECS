data "aws_ecr_repository" "ecr_repo" {
  name = "${var.app}-${var.ecr_repo_name}"
}