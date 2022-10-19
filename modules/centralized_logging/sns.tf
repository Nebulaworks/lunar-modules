resource "aws_sns_topic" "lambda_cloudwatch_logging_errors" {
  name         = "centralized-logging-lambda-errors-${local.region}"
  display_name = "centralized-logging-lambda-errors-${local.region}"
}
