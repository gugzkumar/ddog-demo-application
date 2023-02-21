locals {
  website_url = "${var.aws_prefix}.gugz.net"
}

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = local.website_url
  acl    = "private"
  tags   = var.common_tags
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = local.website_url
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  domain_name = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
  origin_id   = local.website_url
  s3_origin_config {
    origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
  }
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"



  tags = var.common_tags

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.b.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

