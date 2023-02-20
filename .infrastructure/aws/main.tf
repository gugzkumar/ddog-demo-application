# Create a private S3 bucket for storing Terraform state
resource "aws_s3_bucket" "data_lake" {
  bucket = "${var.aws_prefix}-data-lake"
  acl    = "private"
  tags   = var.common_tags
}

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
