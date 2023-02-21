locals {
  app_name       = "sympl-reserve"
  aws_account_id = "648401562011"
  front_domain   = "sympl.jp"
  api_domain     = "api.sympl.jp"
  db_username    = "sympl_user"
  db_password    = random_id.db_password.b64_url
  host_zone_id   = "Z01806201YR9MHQQD665Z"
  # cf_certificate_arn = "arn:aws:acm:us-east-1:138693284518:certificate/d8b8eb47-435d-4e8e-be67-9047e302e2f5"
}

resource "random_id" "db_password" {
  byte_length = 8
}
