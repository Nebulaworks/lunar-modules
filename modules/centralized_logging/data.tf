data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_id                         = data.aws_caller_identity.current.account_id
  region                             = data.aws_region.current.name
  tags                               = var.tags
  firehose_delivery_stream_s3_prefix = var.firehose_log_group_name == "" ? "${var.env}/${local.account_id}/cloudwatch-logs/" : var.firehose_delivery_stream_s3_prefix
  firehose_log_group_name            = var.firehose_log_group_name == "" ? "/aws/kinesisfirehose/${local.region}-cloudwatch-logs" : var.firehose_log_group_name

  lambda_function_name  = var.lambda_config.function_name == "" ? "centralized-logging" : var.lambda_config.function_name
  lambda_log_group_name = var.lambda_log_group_name == "" ? "/aws/lambda/${local.lambda_function_name}" : var.firehose_log_group_name

}
