### Create Route53 Resources
resource "aws_route53_zone" "my_hosted_zone" {
  name = var.aws_hosted_zone_name
  
  tags = {
    Name = "${var.app}-zone"
  }
}

resource "aws_route53_record" "alb_alias" {
  zone_id = aws_route53_zone.my_hosted_zone.zone_id
  name    = "nginxapp.${aws_route53_zone.my_hosted_zone.name}"
  type    = "A"

  alias {
    name                   = aws_lb.ecs_alb.dns_name
    zone_id                = aws_lb.ecs_alb.zone_id
    evaluate_target_health = true
  }
}

### Create ALB Resources
resource "aws_security_group" "alb_sg" {
  name        = "${var.app}-alb-sg"
  description = "ECS ALB Security Group"
  vpc_id      = var.aws_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.aws_ingress_ip
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    ManagedBy = "terraform"
  }
}

resource "aws_lb" "ecs_alb" {
  name               = "${var.app}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.aws_subnet_id

  enable_deletion_protection = false

  tags = {
    ManagedBy = "terraform"
  }
}

resource "aws_lb_target_group" "ecs_lb_target_group" {
  name        = "${var.app}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.aws_vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = {
    ManagedBy = "terraform"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = var.host_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_lb_target_group.arn
  }
}

### Create VPC endpoints
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.aws_vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true  # Enable DNS
  
  subnet_ids          = var.aws_subnet_id
  security_group_ids  = [aws_security_group.alb_sg.id]
  
  tags = {
    Name = "${var.app}-ecr-api-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.aws_vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true  # Enable DNS

  subnet_ids          = var.aws_subnet_id
  security_group_ids  = [aws_security_group.alb_sg.id]

  tags = {
    Name = "${var.app}-ecr-dkr-endpoint"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.aws_vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  
  route_table_ids   = ["rtb-0763e72067676bcae"] # FIXME: Temporary hardcode
  
  tags = {
    Name = "${var.app}-s3-endpoint"
  }
}

### Create for ECS Fargate Resources
# ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    ManagedBy   = "terraform"
  }
}

# ECS IAM Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_ecr_combined_policy" {
  name        = "${var.app}-ecs-ecr-combined"
  description = "ECS IAM policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "ecs:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_ecr_combined_policy.arn
}


# ECS Task Definition
resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "${var.app}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.app}-container"
      image     = "${data.aws_ecr_repository.ecr_repo.repository_url}:${var.aws_ecr_tag}"
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.host_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.app}"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.app}-task-def"
    ManagedBy = "terraform"
  }
}

# Create relevant CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.app}"
  retention_in_days = 7

  tags = {
    ManagedBy = "terraform"
  }
}

# Start ECS service
resource "aws_ecs_service" "main" {
  name            = "${var.app}-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.aws_subnet_id
    security_groups  = [aws_security_group.alb_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_lb_target_group.arn
    container_name   = "${var.app}-container"
    container_port   = var.container_port
  }

  depends_on = [
    aws_lb_listener.front_end
  ]

  tags = {
    ManagedBy = "terraform"
  }
}