# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"
  
  tags = local.common_tags
}

# Security Group for ECS
resource "aws_security_group" "ecs" {
  name_prefix = "${var.app_name}-ecs-"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(local.common_tags, {
    Name = "${var.app_name}-ecs-sg"
  })
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.app_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.size_config[var.size].ecs_cpu
  memory                   = local.size_config[var.size].ecs_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  
  container_definitions = jsonencode([
    {
      name  = var.app_name
      image = "nginx:latest"
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      environment = concat([
        {
          name  = "DATABASE_URL"
          value = "postgresql://postgres:${random_password.db_password.result}@${aws_rds_cluster.main.endpoint}/${replace(var.app_name, "-", "_")}"
        },
        {
          name  = "S3_BUCKET_NAME"
          value = aws_s3_bucket.objects.bucket
        },
        {
          name  = "SNS_TOPIC_ARN"
          value = aws_sns_topic.events.arn
        },
        {
          name  = "AWS_REGION"
          value = var.region
        }
      ], [
        for key, value in var.environment_variables : {
          name  = key
          value = value
        }
      ])
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
  
  tags = local.common_tags
}

# ECS Service
resource "aws_ecs_service" "app" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  network_configuration {
    security_groups = [aws_security_group.ecs.id]
    subnets         = aws_subnet.private[*].id
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = var.app_name
    container_port   = 80
  }
  
  depends_on = [aws_lb_listener.https]
  
  tags = local.common_tags
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = 7
  
  tags = local.common_tags
}