# Sets up a ECS EC2 cluster for the backend
# Copied some of the code from here: 
# https://medium.com/@awsyadav/automating-ecs-ec2-type-deployments-with-terraform-569863c60e69
# and https://github.com/ronnic1/aws-ecs-ec2-project

# ECS cluster and underlying resources (EC2, AutoScaling, Loadbalancing etc.)

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.aws_prefix}-cluster"
  tags = var.common_tags
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
  port     = "4000"
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