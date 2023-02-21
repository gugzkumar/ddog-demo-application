# S3 Bucket for log collection
resource "aws_s3_bucket" "log_collection" {
  bucket = "${var.aws_prefix}-log-collection"
  tags   = var.common_tags
}

resource "aws_s3_bucket_acl" "log_collection_bucket_acl" {
  bucket = aws_s3_bucket.log_collection.id
  acl    = "log-delivery-write"
}

