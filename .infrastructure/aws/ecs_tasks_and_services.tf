# Actual Services and Tasks
resource "aws_ecr_repository" "api-image-repo" {
  name = "${var.aws_prefix}-api"
  tags = var.common_tags
}

# Service role
data "aws_iam_policy_document" "api-service-policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "api-service-role" {
  name               = "${var.aws_prefix}-api-service-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.api-service-policy.json
  tags               = var.common_tags
}

resource "aws_iam_role_policy_attachment" "api-service-role-attachment" {
  role       = aws_iam_role.api-service-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_policy" "ecr-access" {
  name = "${var.aws_prefix}-ecr-access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr-access-role-attachment" {
  role       = aws_iam_role.api-service-role.name
  policy_arn = aws_iam_policy.ecr-access.arn
}

resource "aws_ecs_task_definition" "api-task-definition" {
  container_definitions = jsonencode([
    {
      name  = "${var.aws_prefix}-api"
      image = "${var.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${var.aws_prefix}-api:latest"
      cpu       = 256
      memory    = 512
      portMappings = [
        {
          containerPort = 4000
          hostPort      = 4000
        }
      ]
      environment = [
        {
          name  = "S3_DATA_LAKE_BUCKET"
          value = "${var.aws_prefix}-data-lake"
        },
        {
          name = "AWS_DEFAULT_REGION",
          value = "us-east-1"
        },
        {
          name = "DATADOG_API_KEY",
          value = var.DATADOG_API_KEY
        },
        {
          name = "DATADOG_APP_KEY",
          value = var.DATADOG_APP_KEY
        }
      ]
    }
  ])

  execution_role_arn       = aws_iam_role.api-service-role.arn
  family                   = "${var.aws_prefix}-api-task-definition"
  network_mode             = "bridge"
  memory                   = "2048"
  cpu                      = "1024"
  requires_compatibilities = ["EC2"]
  task_role_arn            = aws_iam_role.api-service-role.arn
  tags                     = var.common_tags
}

resource "aws_ecs_service" "api-service" {

  cluster              = aws_ecs_cluster.ecs-cluster.id # ecs cluster id
  desired_count        = 1                              # no of task running
  launch_type          = "EC2"
  name                 = "${var.aws_prefix}-api-service"
  task_definition      = aws_ecs_task_definition.api-task-definition.arn
  force_new_deployment = true

  load_balancer {
    container_name   = "${var.aws_prefix}-api"
    container_port   = 4000
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }

}

resource "aws_ecs_service" "datadog-agent-service" {
  cluster             = aws_ecs_cluster.ecs-cluster.id # ecs cluster id
  launch_type         = "EC2"
  name                = "datadog-agent"
  task_definition     = var.datadog_agent_task_def_arn
  scheduling_strategy = "DAEMON"
}

