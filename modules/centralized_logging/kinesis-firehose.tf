resource "aws_kinesis_firehose_delivery_stream" "cloudwatch_logs" {
  name        = "cloudwatch-logs-${local.region}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.kinesis_firehose_s3_logging.arn
    bucket_arn         = "arn:aws:s3:::${var.s3_logging_bucket}"
    buffer_size        = var.firehose_delivery_stream_buffer_size
    buffer_interval    = var.firehose_delivery_stream_buffer_interval
    compression_format = var.firehose_delivery_stream_compression_format
    prefix             = local.firehose_delivery_stream_s3_prefix
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "/aws/kinesisfirehose/${local.region}-cloudwatch-logs"
      log_stream_name = "S3Delivery"
    }
  }
}
