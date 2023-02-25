output "datadog_agent_task_def_arn" {
  value = aws_ecs_task_definition.ddog-task-definition.arn
}