resource "aws_s3_bucket" "front" {
  bucket = "${local.app_name}-${terraform.workspace}-front"

  policy = templatefile(
    "policies/s3_cloudfront_front_bucket_policy.tmpl",
    {
      sid_name                  = "Front",
      origin_access_identity_id = aws_cloudfront_origin_access_identity.front.id,
      app_name                  = local.app_name,
      env                       = terraform.workspace,
      name                      = "front"
    }
  )
}

resource "aws_s3_bucket" "api_uploads" {
  bucket = "${local.app_name}-api-${terraform.workspace}-uploads"

  policy = templatefile(
    "policies/s3_cloudfront_front_bucket_policy.tmpl",
    {
      sid_name                  = "ApiUploads",
      origin_access_identity_id = aws_cloudfront_origin_access_identity.api_uploads.id,
      app_name                  = "${local.app_name}-api",
      env                       = terraform.workspace,
      name                      = "uploads"
    }
  )
}
