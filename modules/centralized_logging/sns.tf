resource "aws_sns_topic" "lambda_cloudwatch_logging_errors" {
  name         = "cloudwatch-logging-lambda-errors-${local.region}"
  display_name = "cloudwatch-logging-lambda-errors-${local.region}"
}
