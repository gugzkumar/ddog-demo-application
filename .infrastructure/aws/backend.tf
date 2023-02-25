# Sets up a ECS EC2 cluster for the backend
# Copied some of the code from here: 
# https://medium.com/@awsyadav/automating-ecs-ec2-type-deployments-with-terraform-569863c60e69
# and https://github.com/ronnic1/aws-ecs-ec2-project

# ECR and ECS for Backend
resource "aws_ecr_repository" "api-image-repo" {
  name = "${var.aws_prefix}-api"
  tags = var.common_tags
}

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.aws_prefix}-cluster"
  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "api_log_group" {
  name = "${var.aws_prefix}-api-log-group"
  tags = var.common_tags
}

resource "aws_ecs_task_definition" "api-task-definition" {
  container_definitions = jsonencode([
    {
      name  = "${var.aws_prefix}-api"
      image = "${var.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${var.aws_prefix}-api:latest"
      portMappings = [
        {
          containerPort = 6000
          hostPort      = 6000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = aws_cloudwatch_log_group.api_log_group.name
          # "${var.aws_prefix}-api-log-group}"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "${var.aws_prefix}-api}"
        }
      }
    }
  ])

  # network_mode           = "awsvpc"
  execution_role_arn       = aws_iam_role.api-service-role.arn
  family                   = "${var.aws_prefix}-api-task-definition"
  network_mode             = "bridge"
  memory                   = "2048"
  cpu                      = "1024"
  requires_compatibilities = ["EC2"]
  task_role_arn            = aws_iam_role.api-service-role.arn
  tags                     = var.common_tags
}

resource "aws_lb" "loadbalancer" {
  internal           = false
  load_balancer_type = "application"
  name               = "${var.aws_prefix}-api-loadbalancer"
  subnets            = var.AWS_SUBNETS
  tags               = var.common_tags
}

resource "aws_lb_target_group" "lb_target_group" {
  name     = "${var.aws_prefix}-api-lb-tg"
  port     = "6000"
  protocol = "HTTP"
  vpc_id   = var.AWS_VPC_ID
  tags     = var.common_tags
}

resource "aws_lb_listener" "lb_listener" {
  default_action {
    target_group_arn = aws_lb_target_group.lb_target_group.id
    type             = "forward"
  }

  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"
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
  name        = "${var.aws_prefix}-ecr-access"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr-access-role-attachment" {
  role       = aws_iam_role.api-service-role.name
  policy_arn = aws_iam_policy.ecr-access.arn
}

data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent" {
  name               = "${var.aws_prefix}-ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}


resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "${var.aws_prefix}-ecs-agent"
  role = aws_iam_role.ecs_agent.name
}

resource "aws_launch_configuration" "ecs_launch_config_2" {
  image_id             = "ami-05e7fa5a3b6085a75"
  iam_instance_profile = aws_iam_instance_profile.ecs_agent.id
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=${var.aws_prefix}-cluster >> /etc/ecs/ecs.config"
  instance_type        = "t2.medium"
  key_name             = "gagan" #CHANGE THIS TO ANOTHER KEY
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                      = "${var.aws_prefix}-ecs-asg"
  vpc_zone_identifier       = var.AWS_SUBNETS
  launch_configuration      = aws_launch_configuration.ecs_launch_config_2.name
  target_group_arns         = [aws_lb_target_group.lb_target_group.arn]
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  protect_from_scale_in     = true
  tag {
    key                 = "Name"
    value               = "${var.aws_prefix}-ecs-node"
    propagate_at_launch = true
  }
  tag {
    key                 = "Application"
    value               = var.common_tags.Application
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = var.common_tags.Environment
    propagate_at_launch = true
  }
  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "ecs-capacity-provider" {
  name = "${var.aws_prefix}-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 1
    }
  }
}

# Actual Services
resource "aws_ecs_service" "api-service" {

  cluster              = aws_ecs_cluster.ecs-cluster.id # ecs cluster id
  desired_count        = 1                              # no of task running
  launch_type          = "EC2"
  name                 = "${var.aws_prefix}-api-service"
  task_definition      = aws_ecs_task_definition.api-task-definition.arn
  force_new_deployment = true

  load_balancer {
    container_name   = "${var.aws_prefix}-api"
    container_port   = 6000
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }

  # network_configuration {
  #   subnets          = var.AWS_SUBNETS ## Enter the private subnet id
  #   assign_public_ip = "true"
  # }
}

resource "aws_ecs_service" "datadog-agent-service" {
  cluster             = aws_ecs_cluster.ecs-cluster.id # ecs cluster id
  launch_type         = "EC2"
  name                = "datadog-agent"
  task_definition     = var.datadog_agent_task_def_arn
  scheduling_strategy = "DAEMON"
}
