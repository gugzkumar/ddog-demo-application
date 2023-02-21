# Sets up a static website on AWS S3 and CloudFront using Terraform
# Copied some of the code from here: 
# https://towardsaws.com/provision-a-static-website-on-aws-s3-and-cloudfront-using-terraform-d8004a8f629a

locals {
  website_url = "${var.aws_prefix}.gugz.net"
}

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = local.website_url
  tags   = var.common_tags
}

resource "aws_s3_bucket_website_configuration" "frontend_bucket_website_configuration" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_acl" "frontend_bucket_acl" {
  bucket = aws_s3_bucket.frontend_bucket.id
  acl    = "public-read"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = local.website_url
}

resource "aws_cloudfront_distribution" "s3_distribution" {

  origin {
    domain_name = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id   = local.website_url
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"


  tags = var.common_tags
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.website_url

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

# resource "aws_s3_bucket_public_access_block" "frontend_bucket_public_access_block" {
#   bucket              = aws_s3_bucket.frontend_bucket.id
#   block_public_acls   = true
#   block_public_policy = true
# }
