# Sets up a ECS EC2 cluster for the backend
# Copied some of the code from here: 
# https://medium.com/@awsyadav/automating-ecs-ec2-type-deployments-with-terraform-569863c60e69

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
  ami                    = "ami-0dfcb1ef8550277af"
  instance_type          = "t2.medium"
  iam_instance_profile   = aws_iam_instance_profile.api-instance-profile.id
  key_name               = "gagan" #CHANGE THIS
  user_data              = "${data.template_file.user_data.rendered}"

  tags = var.common_tags

  lifecycle {
    ignore_changes         = ["ami", "user_data", "key_name", "private_ip"]
  }
}


data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.tpl")}"
}

