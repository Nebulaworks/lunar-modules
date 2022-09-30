resource "aws_lambda_function" "cloudwatch_logging" {
  description   = "Creates cloudwatch subscription filter that forwards cloudwatch logs to a firehose delivery stream"
  function_name = local.lambda_function_name

  s3_bucket         = try(var.lambda_config.s3_package_bucket, null)
  s3_key            = try(var.lambda_config.s3_package_prefix, null)
  s3_object_version = try(var.lambda_config.s3_package_object_version, null)

  role        = aws_iam_role.lambda_cloudwatch_logging.arn
  memory_size = var.lambda_config.memory_size
  runtime     = var.lambda_config.runtime
  timeout     = var.lambda_config.timeout
  handler     = "centralized_logging.lambda_handler"

  environment {
    variables = {
      kinesis_firehose_delivery_stream_arn      = aws_kinesis_firehose_delivery_stream.cloudwatch_logs.arn
      cloudwatch_logs_kinesis_firehose_role_arn = aws_iam_role.cloudwatch_logs_kinesis_firehose_logging.arn
      cloudtrail_log_group                      = var.cloudtrail_log_group_name
    }
  }

  dynamic "vpc_config" {
    for_each = length(var.lambda_config.vpc_subnet_ids) != 0 && length(var.lambda_config.vpc_security_group_ids) != 0 ? [1] : []
    content {
      security_group_ids = var.lambda_config.vpc_security_group_ids
      subnet_ids         = var.lambda_config.vpc_subnet_ids
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda_logging]
  tags       = local.tags
}

resource "aws_lambda_permission" "cloudwatch_log_create" {
  statement_id  = "cloudwatch-log-group-create"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudwatch_logging.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cloudwatch_log_group_create.arn
}
