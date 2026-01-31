################################
# Terraform & Provider
################################
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

################################
# Variables
################################
variable "project_name" {
  default = "ecs-fargate-cicd-terraform"
}

variable "container_image" {
  description = "ECR image URI"
  type        = string
}

variable "container_port" {
  default = 8080
}

variable "ecs_task_execution_role_arn" {
  description = "Existing ECS Task Execution Role ARN"
  type        = string
}

################################
# VPC
################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "${var.project_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-north-1a", "eu-north-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

################################
# Security Group
################################
resource "aws_security_group" "ecs" {
  name   = "${var.project_name}-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allow app traffic"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

################################
# CloudWatch Log Group
################################
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7
}

################################
# ECS Cluster
################################
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.11.4"

  cluster_name = "${var.project_name}-cluster"

  # We create log group manually
  create_cloudwatch_log_group = false
}

################################
# ECS Task Definition
################################
resource "aws_ecs_task_definition" "app" {
  family                   = var.project_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  execution_role_arn = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.project_name}"
          awslogs-region        = "eu-north-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

################################
# ECS Service (Fargate)
################################
resource "aws_ecs_service" "app" {
  depends_on = [
    aws_cloudwatch_log_group.ecs
  ]

  name            = var.project_name
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = module.vpc.public_subnets
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
}

################################
# Outputs
################################
output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}
