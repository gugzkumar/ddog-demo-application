# Sets up a ECS EC2 cluster for the backend
# Copied some of the code from here: 
# https://medium.com/@awsyadav/automating-ecs-ec2-type-deployments-with-terraform-569863c60e69
# and https://github.com/ronnic1/aws-ecs-ec2-project

# ECR and ECS for Backend
resource "aws_ecr_repository" "api-instance" {
  name = "${var.aws_prefix}-api"
  tags = var.common_tags
}

resource "aws_ecs_cluster" "api-instance-cluster" {
  name = "${var.aws_prefix}-cluster"
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
    }
  ])

  execution_role_arn       = aws_iam_role.api-service-role.arn
  family                   = "${var.aws_prefix}-api-task-definition"
  network_mode             = "awsvpc"
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

# Instance role
data "aws_iam_policy_document" "ecs-instance-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "api-instance-role" {
  name               = "${var.aws_prefix}-api-instance-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs-instance-policy.json
  tags               = var.common_tags
}

resource "aws_iam_instance_profile" "api-instance-profile" {
  name = "${var.aws_prefix}-api-instance-profile"
  path = "/"
  role = aws_iam_role.api-instance-role.id
  provisioner "local-exec" {
    command = "sleep 60"
  }
  tags = var.common_tags
}

# Service role
data "aws_iam_policy_document" "api-service-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
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


# EC2 Instance
resource "aws_instance" "ec2_instance" {
  ami                  = "ami-0dfcb1ef8550277af"
  instance_type        = "t2.medium"
  iam_instance_profile = aws_iam_instance_profile.api-instance-profile.id
  key_name             = "gagan" #CHANGE THIS TO ANOTHER KEY
  user_data            = data.template_file.user_data.rendered

  tags = merge(
    var.common_tags,
    {
      Name = "${var.aws_prefix}-ecs-node"
    }
  )

  lifecycle {
    ignore_changes = [ami, user_data, key_name, private_ip]
  }
}


data "template_file" "user_data" {
  template = file("${path.module}/user_data.tpl")
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

resource "aws_launch_configuration" "ecs_launch_config" {
  image_id             = "ami-094d4d00fd7462815"
  iam_instance_profile = aws_iam_instance_profile.ecs_agent.id
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=${var.aws_prefix}-cluster >> /etc/ecs/ecs.config"
  instance_type        = "t2.medium"
  key_name             = "gagan" #CHANGE THIS TO ANOTHER KEY
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                      = "${var.aws_prefix}-ecs-asg"
  vpc_zone_identifier       = var.AWS_SUBNETS
  launch_configuration      = aws_launch_configuration.ecs_launch_config.name
  target_group_arns         = [aws_lb_target_group.lb_target_group.arn]
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  tags                       = concat([var.common_tags])
}

# Actual Services
# resource "aws_ecs_service" "service" {
#   cluster         = aws_ecs_cluster.cluster.id                  # ecs cluster id
#   desired_count   = 1                                           # no of task running
#   launch_type     = "EC2"                                       # Cluster type ECS OR FARGATE
#   name            = "openapi-service"                           # Name of service
#   task_definition = aws_ecs_task_definition.task_definition.arn # Attaching Task to service
#   load_balancer {
#     container_name   = "openapi-ecs-container" #"container_${var.component}_${var.environment}"
#     container_port   = "8080"
#     target_group_arn = aws_lb_target_group.lb_target_group.arn # attaching load_balancer target group to ecs
#   }
#   network_configuration {
#     security_groups  = ["sg-01849003c4f9203ca"]             #CHANGE THIS
#     subnets          = ["${var.subnet1}", "${var.subnet2}"] ## Enter the private subnet id
#     assign_public_ip = "false"
#   }
#   depends_on = ["aws_lb_listener.lb_listener"]
# }
