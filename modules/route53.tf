resource "aws_route53_record" "front" {
  zone_id = local.host_zone_id
  name    = local.front_domain
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.front.domain_name
    zone_id                = aws_cloudfront_distribution.front.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "api" {
  zone_id = local.host_zone_id
  name    = local.api_domain
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.api.domain_name
    zone_id                = aws_cloudfront_distribution.api.hosted_zone_id
    evaluate_target_health = false
  }
}
