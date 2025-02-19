provider "aws" {
  region = "us-west-2"
}

resource "aws_ecs_cluster" "tictactoe_cluster" {
  name = "tictactoe-cluster"
}

resource "aws_ecs_task_definition" "tictactoe_task" {
  family = "tictactoe-task"

  container_definitions = jsonencode([
    {
      name      = "tictactoe-container"
      image     = "my-docker-image"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "tictactoe_service" {
  name            = "tictactoe-service"
  cluster         = aws_ecs_cluster.tictactoe_cluster.id
  task_definition = aws_ecs_task_definition.tictactoe_task.arn
  desired_count   = 1

  launch_type = "FARGATE"

  network_configuration {
    subnets = ["subnet-12345678"]
    security_groups = ["sg-12345678"]
    assign_public_ip = true
  }
}
