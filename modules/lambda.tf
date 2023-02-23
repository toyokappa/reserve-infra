provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

data "archive_file" "admin_basic_auth" {
  type        = "zip"
  source_dir  = "lambda/admin_basic_auth"
  output_path = "lambda/dist/admin_basic_auth.zip"
}

resource "aws_lambda_function" "admin_basic_auth" {
  provider         = aws.virginia
  function_name    = "${local.app_name}-${terraform.workspace}-admin-basic-auth"
  role             = aws_iam_role.lambda_edge.arn
  filename         = data.archive_file.admin_basic_auth.output_path
  handler          = "index.handler"
  source_code_hash = data.archive_file.admin_basic_auth.output_base64sha256
  runtime          = "nodejs16.x"

  publish = true
}
