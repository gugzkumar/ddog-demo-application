# ECR and ECS for Backend
resource "aws_ecr_repository" "api-instance" {
  name = "${var.aws_prefix}-api-instance"
  tags = var.common_tags
}

resource "aws_ecs_cluster" "api-instance-cluster" {
  name = "${var.aws_prefix}-my-cluster"
  tags = var.common_tags
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
data "aws_iam_policy_document" "ecs-service-policy" {
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
  assume_role_policy = data.aws_iam_policy_document.ecs-service-policy.json
  tags               = var.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs-service-role-attachment" {
  role       = aws_iam_role.ecs-service-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}
