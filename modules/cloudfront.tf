resource "aws_cloudfront_distribution" "front" {
  wait_for_deployment = false
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${local.app_name}-${terraform.workspace}-front"
  default_root_object = ""
  aliases             = [local.front_domain]

  origin {
    domain_name = aws_s3_bucket.front.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.front.id

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.front.id}"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["HEAD", "GET", "OPTIONS"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = aws_s3_bucket.front.id
    compress         = true

    forwarded_values {
      query_string = true
      headers      = ["Origin"]
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = local.cf_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = 0
    response_page_path    = "/index.html"
    response_code         = 200
  }
}

resource "aws_cloudfront_distribution" "api" {
  wait_for_deployment = false
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${local.app_name}-${terraform.workspace}-api"
  default_root_object = ""
  aliases             = [local.api_domain]

  origin {
    domain_name = aws_instance.ecs_instance.public_dns
    origin_id   = aws_instance.ecs_instance.id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      origin_protocol_policy = "http-only"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = aws_instance.ecs_instance.id
    compress         = true

    forwarded_values {
      query_string = true
      headers      = ["Authorization", "Origin"]
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  #----------------------------------------------------------
  # uploads bucket
  origin {
    domain_name = aws_s3_bucket.api_uploads.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.api_uploads.id

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.api_uploads.id}"
    }
  }

  ordered_cache_behavior {
    path_pattern     = "/uploads/*"
    allowed_methods  = ["HEAD", "GET", "OPTIONS"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = aws_s3_bucket.api_uploads.id
    compress         = true

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # uploads bucket
  #----------------------------------------------------------

  viewer_certificate {
    acm_certificate_arn      = local.cf_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = 0
    response_page_path    = "/index.html"
    response_code         = 200
  }
}

resource "aws_cloudfront_origin_access_identity" "front" {
  comment = "${local.app_name}-${terraform.workspace}-front"
}

resource "aws_cloudfront_origin_access_identity" "api_uploads" {
  comment = "${local.app_name}-api-${terraform.workspace}-uploads"
}
