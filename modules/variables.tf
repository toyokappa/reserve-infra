locals {
  app_name           = "sympl-reserve"
  aws_account_id     = "648401562011"
  front_domain       = "sympl.jp"
  api_domain         = "api.sympl.jp"
  db_username        = "sympl_user"
  db_password        = random_id.db_password.b64_url
  host_zone_id       = "Z01806201YR9MHQQD665Z"
  cf_certificate_arn = "arn:aws:acm:us-east-1:648401562011:certificate/f2f4be9e-01ff-427e-8cfe-b9546a0fe301"
}

resource "random_id" "db_password" {
  byte_length = 8
}
