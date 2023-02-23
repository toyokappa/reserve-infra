# EC2インスタンス用ロール
resource "aws_iam_instance_profile" "ecs_instance" {
  name = "${local.app_name}-api-${terraform.workspace}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance.name
}

resource "aws_iam_role" "ecs_instance" {
  name               = "${local.app_name}-api-${terraform.workspace}-ecs-instance-role"
  assume_role_policy = file("policies/ec2_assume_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs_service" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = aws_iam_role.ecs_instance.id
}

# ECS Execution用ロール
resource "aws_iam_role" "ecs_execution" {
  name               = "${local.app_name}-api-${terraform.workspace}-ecs-execution-role"
  assume_role_policy = file("policies/ecs_tasks_assume_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
  role       = aws_iam_role.ecs_execution.id
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_execution.id
}

resource "aws_iam_policy" "ssm_get_policy" {
  name   = "${local.app_name}-${terraform.workspace}-ssm-get-policy"
  policy = templatefile("policies/ssm_get_policy.tmpl", { aws_account_id = local.aws_account_id })
}

resource "aws_iam_role_policy_attachment" "ssm_get_for_ecs_execution" {
  policy_arn = aws_iam_policy.ssm_get_policy.arn
  role       = aws_iam_role.ecs_execution.name
}

# ECS Task用ロール
resource "aws_iam_role" "ecs_task_role" {
  name               = "${local.app_name}-api-${terraform.workspace}-ecs-task-role"
  assume_role_policy = file("policies/ecs_tasks_assume_role_policy.json")
}

resource "aws_iam_role_policy" "ecs_task_policy" {
  name   = "${local.app_name}-api-${terraform.workspace}-ecs-task-policy"
  role   = aws_iam_role.ecs_task_role.name
  policy = file("policies/ecs_task_policy.json")
}

resource "aws_iam_role" "lambda_edge" {
  name               = "${local.app_name}-lambda-edge-role"
  assume_role_policy = file("policies/lambda_edge_assume_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_edge.name
}

resource "aws_iam_role_policy_attachment" "ssm_get_for_lambda" {
  policy_arn = aws_iam_policy.ssm_get_policy.arn
  role       = aws_iam_role.lambda_edge.name
}
