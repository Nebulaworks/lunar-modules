output "cloudwatch_logs_kinesis_firehose_logging_role_arn" {
  description = "ARN of IAM role used by CloudWatch logs subscription filter to forward logs to Kinesis Data Firhose Delivery stream"
  value       = aws_iam_role.cloudwatch_logs_kinesis_firehose_logging.arn
}

output "kinesis_firehose_s3_logging_role_arn" {
  description = "ARN of IAM role used by Kinesis Firehose delivery stream to push objects to the s3 logging bucket"
  value       = aws_iam_role.kinesis_firehose_s3_logging.arn
}

output "lambda_cloudwatch_logging_role_arn" {
  description = "ARN of IAM role used by centralized-logging lamdba"
  value       = aws_iam_role.kinesis_firehose_s3_logging.arn
}

output "lambda_cloudwatch_logging_errors_sns_topic" {
  description = "ARN of SNS topic for centralized-logging lambda errors"
  value       = aws_sns_topic.lambda_cloudwatch_logging_errors.arn
}
