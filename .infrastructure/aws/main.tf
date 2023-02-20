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

# resource "aws_s3_bucket_logging" "example" {
#   bucket = aws_s3_bucket.data_lake.id
#   target_bucket = aws_s3_bucket.log_collection.id
#   target_prefix = "log/"
# }


# Create a serverles Redshift cluster for the data warehouse
# resource "aws_redshift_cluster" "data_warehouse" {
#   cluster_identifier = "${var.aws_prefix}-data-warehouse"
#   database_name      = "data_warehouse"
#   master_username    = "admin"
#   master_password    = "password"
#   node_type          = "dc2.large"
#   cluster_type       = "single-node"
#   number_of_nodes    = 1
#   skip_final_snapshot = true
#   tags               = var.common_tags
# }
