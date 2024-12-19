
locals {
  lambda_api_zip = "${var.lambda_name}-${var.environment}_payload.zip"
}

data "archive_file" "lambda_api" {
  type        = "zip"
  source_dir  = "src"
  output_path = local.lambda_api_zip
}

resource "aws_lambda_function" "lambda_api" {
  filename         = local.lambda_api_zip
  function_name    = "${var.lambda_name}-${var.environment}"
  handler          = "main.lambda_handler"
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.11"
  source_code_hash = data.archive_file.lambda_api.output_base64sha256
  memory_size      = var.memory_size

  environment {
    variables = {
      env           = var.environment
    }
  }

}

resource "aws_lambda_function_url" "lambda_api" {
  function_name      = aws_lambda_function.lambda_api.function_name
  authorization_type = "NONE"
}

# Cloudwatch logs
resource "aws_cloudwatch_log_group" "lambda_api" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_api.function_name}"
  retention_in_days = 1
}