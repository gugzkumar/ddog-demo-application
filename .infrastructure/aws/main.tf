# ECR and ECS for Backend
resource "aws_ecr_repository" "api-service" {
  name = "${var.aws_prefix}-api-service"
  tags   = var.common_tags
}

resource "aws_ecs_cluster" "api-service-cluster" {
  name = "${var.aws_prefix}-my-cluster"
  tags   = var.common_tags
}
