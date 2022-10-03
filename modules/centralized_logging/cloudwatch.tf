###########
# CloudWatch Log Groups
###########

resource "aws_cloudwatch_log_group" "lambda_logging" {
  name              = local.lambda_log_group_name
  retention_in_days = var.lambda_log_group_retention
  tags              = local.tags
}

resource "aws_cloudwatch_log_group" "firehose_error_logging" {
  name              = local.firehose_log_group_name
  retention_in_days = var.firehose_log_group_retention
  tags              = local.tags
}

##########
# Cloudwatch Logs Streams 
##########

resource "aws_cloudwatch_log_stream" "firehose_error_logging" {
  name           = "S3Delivery"
  log_group_name = aws_cloudwatch_log_group.firehose_error_logging.name
}

##########
# Cloudwatch Event Rules
##########

resource "aws_cloudwatch_event_rule" "cloudwatch_log_group_create" {
  name        = "cloudwatch-log-group-create-${local.region}"
  description = "Cloudwatch log group creation"

  event_pattern = <<EOF
{
  "source": [
    "aws.logs"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "logs.amazonaws.com"
    ],
    "eventName": [
      "CreateLogGroup"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "lambda_cron" {
  name                = "lambda-centralized-logging-cron-${local.region}"
  description         = "Periodic trigger for the centralized-logging lambda"
  schedule_expression = var.cloudwatch_schedule_expression
}

##########
# Cloudwatch Event Target
##########

resource "aws_cloudwatch_event_target" "cloudwatch_log_group_create" {
  target_id = "cloudwatch-log-group-creation-${local.region}"
  rule      = aws_cloudwatch_event_rule.cloudwatch_log_group_create.name
  arn       = aws_lambda_function.cloudwatch_logging.arn
}

resource "aws_cloudwatch_event_target" "lambda_cron" {
  target_id = "lambda-centralized-logging-cron-${local.region}"
  rule      = aws_cloudwatch_event_rule.lambda_cron.name
  arn       = aws_lambda_function.cloudwatch_logging.arn
}

##########
# Cloudwatch Metric Alarms
##########

resource "aws_cloudwatch_metric_alarm" "lambda_cloudwatch_logging" {
  alarm_name          = "lambda-centralized-logging-failed-${local.region}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  dimensions = {
    FunctionName = aws_lambda_function.cloudwatch_logging.function_name
  }
  treat_missing_data        = "notBreaching"
  statistic                 = "Maximum"
  threshold                 = "0"
  alarm_description         = "This metric monitors the centralized-logging lambda function for errors."
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.lambda_cloudwatch_logging_errors.arn]
}
