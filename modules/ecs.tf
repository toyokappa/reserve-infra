resource "aws_ecs_cluster" "main" {
  name = "${local.app_name}-api-${terraform.workspace}-cluster"
}

resource "aws_ecs_service" "rails" {
  name                               = "${local.app_name}-api-${terraform.workspace}-rails"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = "${local.app_name}-api-${terraform.workspace}-rails:1"
  desired_count                      = 0
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition
    ]
  }
}
