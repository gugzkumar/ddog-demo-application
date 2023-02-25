# ECS task definition for Datadog Agent to be able to monitor containers on an ecs cluster
# https://docs.datadoghq.com/containers/amazon_ecs/?tab=awscli#create-an-ecs-task
resource "aws_ecs_task_definition" "ddog-task-definition" {
  container_definitions = jsonencode([
    {

      name      = "datadog-agent"
      image     = "public.ecr.aws/datadog/agent:latest"
      cpu       = 100
      memory    = 512
      essential = true
      mountPoints = [
        {
          containerPath = "/var/run/docker.sock"
          sourceVolume  = "docker_sock"
          readOnly      = true
        },
        {
          containerPath = "/host/sys/fs/cgroup"
          sourceVolume  = "cgroup"
          readOnly      = true
        },
        {
          containerPath = "/host/proc"
          sourceVolume  = "proc"
          readOnly      = true
        }
      ],
      portMappings = [
        {
          hostPort      = 8125
          protocol      = "udp"
          containerPort = 8125
        }
      ],
      environment = [
        {
          name  = "DD_API_KEY"
          value = var.DATADOG_API_KEY
        },
        {
          name  = "DD_SITE"
          value = "datadoghq.com"
        },
        {
          name  = "DD_DOGSTATSD_NON_LOCAL_TRAFFIC"
          value = "true"
        },
        {
          name  = "DD_PROCESS_AGENT_ENABLED"
          value = "true"
        },
      ]
    }
  ])

  volume {
    name = "docker_sock"
    host_path = "/var/run/docker.sock"
  }

  volume {
    name = "cgroup"
    host_path = "/sys/fs/cgroup"
  }

  volume {
    name = "proc"
    host_path = "/proc"
  }

  execution_role_arn       = "arn:aws:iam::056825751459:role/dev-ddog-demo-api-instance-role"

  family                   = "${var.aws_prefix}-ddog-agent"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  tags                     = var.common_tags
}
