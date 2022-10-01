resource "aws_kinesis_firehose_delivery_stream" "cloudwatch_logs" {
  name        = "cloudwatch-logs-${data.aws_region.current.name}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.kinesis_firehose_s3_logging.arn
    bucket_arn = "arn:aws:s3:::${var.s3_logging_bucket}"
    prefix     = "${var.env}/${data.aws_caller_identity.current.account_id}/cloudwatch-logs/"
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "/aws/kinesisfirehose/${local.region}-cloudwatch-logs"
      log_stream_name = "S3Delivery"
    }
    compression_format = "GZIP" # Default is `UNCOMPRESSED` but we have proven the format is gz
  }
}
