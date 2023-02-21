# S3 Bucket for log collection
resource "aws_s3_bucket" "log_collection" {
  bucket = "${var.aws_prefix}-log-collection"
  tags   = var.common_tags
}

resource "aws_s3_bucket_acl" "log_collection_bucket_acl" {
  bucket = aws_s3_bucket.log_collection.id
  acl    = "log-delivery-write"
}

# Data Lake
resource "aws_s3_bucket" "data_lake" {
  bucket = "${var.aws_prefix}-data-lake"
  tags   = var.common_tags
}

resource "aws_s3_bucket_acl" "data_lake_bucket_acl" {
  bucket = aws_s3_bucket.data_lake.id
  acl    = "private"
}

resource "aws_s3_bucket_metric" "data_lake_bucket_metric" {
  bucket = aws_s3_bucket.data_lake.id
  name   = "${var.aws_prefix}-data-lake-metric"
}

resource "aws_s3_bucket_logging" "data-lake-logging" {
  bucket = aws_s3_bucket.data_lake.id
  target_bucket = aws_s3_bucket.log_collection.id
  target_prefix = "data-lake-logs/"
}


# ECR and ECS for Backend
resource "aws_ecr_repository" "api-service" {
  name = "${var.aws_prefix}-api-service"
}

resource "aws_ecs_cluster" "api-service-cluster" {
  name = "${var.aws_prefix}-my-cluster"
}
