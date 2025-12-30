# ECR repositories
resource "aws_ecr_repository" "ecr_repo" {
  for_each = toset(var.aws_ecr_repo_name)
  name = "${var.aws_ecr_app}-${each.key}"

  # Set immutable for PROD
  image_tag_mutability = each.key == "prod" ? "IMMUTABLE" : "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.aws_ecr_app}-ecr"
    Environment = each.key
    ManagedBy   = "terraform"
  }
}

# ECR lifecycle policy
resource "aws_ecr_lifecycle_policy" "ecr_lifecycle" {
  for_each = toset(var.aws_ecr_repo_name)
  repository = aws_ecr_repository.ecr_repo[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove untagged images older than 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countNumber = 7
          countUnit   = "days"
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep last 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire" # Set it as expire / archive
        }
      }
    ]
  })
}

# ECR repository policy to allow push/pull
resource "aws_ecr_repository_policy" "ecr_repo_policy" {
  for_each = toset(var.aws_ecr_repo_name)
  repository = aws_ecr_repository.ecr_repo[each.key].name

  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Sid    = "AllowPushPull"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root", # Allow all user in the account
          ]
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}