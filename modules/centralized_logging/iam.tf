##########
# IAM Policy Documents
##########

#### AWS CloudWatch Logs

# Cloudwatch Assume Role

data "aws_iam_policy_document" "cloudwatch_logs_assume_role" {
  statement {
    sid    = "CloudWatchLogsAssumeRole"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${local.region}.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:${local.region}:${local.account_id}:*"]
    }
  }
}

# CloudWatch write to Kinesis Data Firehose delivery stream

data "aws_iam_policy_document" "cloudwatch_logs_kinesis_firehose_logging" {
  statement {
    sid    = "CloudWatchWriteKinesisDataFirehose"
    effect = "Allow"
    actions = [
      "firehose:DescribeDeliveryStream",
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]
    resources = [aws_kinesis_firehose_delivery_stream.cloudwatch_logs.arn]
  }

}

#### AWS Kinesis Data Firehose

# AWS Kinesis Firehose Assume role

data "aws_iam_policy_document" "kinesis_firehose_assume_role" {
  statement {
    sid    = "KinesisDataFirehoseAssumeRole"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# Logging bucket read/write permissions

data "aws_iam_policy_document" "kinesis_firehose_s3_logging" {
  statement {
    sid = "S3BucketPermissions"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
    ]

    resources = ["arn:aws:s3:::${var.s3_logging_bucket}"]
  }

  statement {
    sid = "S3ObjectPermissions"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = ["arn:aws:s3:::${var.s3_logging_bucket}/*"]
  }

  dynamic "statement" {
    for_each = var.s3_logging_bucket_kms_key_arn != "" ? [1] : []
    content {
      sid = "KMSPermissions"
      actions = [
        "kms:Encrypt",
        "kms:GenerateDataKey"
      ]
      resources = [var.s3_logging_bucket_kms_key_arn]
    }
  }

  statement {
    sid = "ErrorLoggingCloudWatch"
    actions = [
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.firehose_error_logging.arn}/*:log-stream:*"]
  }
}

#### Lambda

# Lambda Assume Role

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_cloudwatch_logging" {
  statement {
    effect = "Allow"
    sid    = "LambdaLoggingPermissions"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.lambda_logging.arn}:*"]
  }

  statement {
    effect = "Allow"
    sid    = "LambdaCloudWatchPermissions"
    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeSubscriptionFilters",
      "logs:PutSubscriptionFilter",
      "firehose:DescribeDeliveryStream"
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    sid       = "IAMPassRolePermissions"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.cloudwatch_logs_kinesis_firehose_logging.arn]
  }
}

#########
# IAM Roles
#########

##### CloudWatch Logs

resource "aws_iam_role" "cloudwatch_logs_kinesis_firehose_logging" {
  name               = "cloudwatch-logs-kinesis-firehose-logging-${local.region}"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_logs_assume_role.json
  description        = "IAM role used by CloudWatch logs subscription filter to foward logs to Kinesis Data Firehose Delivery stream"
}

##### Kinesis Data Firehose

resource "aws_iam_role" "kinesis_firehose_s3_logging" {
  name               = "kinesis-firehose-s3-logging-${local.region}"
  assume_role_policy = data.aws_iam_policy_document.kinesis_firehose_assume_role.json
  description        = "IAM role used by Kinesis Firehose delivery stream to push objects to the s3 logging bucket"
}

#### Lambda

resource "aws_iam_role" "lambda_cloudwatch_logging" {
  name               = "lambda-cloudwatch-logging-${local.region}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

##########
# IAM Policies
##########

##### Cloudwatch Logs

resource "aws_iam_policy" "cloudwatch_logs_kinesis_firehose_logging" {
  name        = "cloudwatch-logs-kinesis-rw-${local.region}"
  description = "Allows Cloudwatch logs to write to a Kinesis Firehose Delivery stream"
  policy      = data.aws_iam_policy_document.cloudwatch_logs_kinesis_firehose_logging.json
}

##### Kinesis Data Firehose

resource "aws_iam_policy" "kinesis_firehose_s3_logging" {
  name        = "kinesis-firehose-s3-logging-${local.region}"
  description = "Allows Kinesis Data Firehose to read/write logs to s3 logging bucket"
  policy      = data.aws_iam_policy_document.kinesis_firehose_s3_logging.json
}

#### Lambda

resource "aws_iam_policy" "lambda_cloudwatch_logging" {
  name        = "lambda-cloudwatch-logging-${local.region}"
  description = "Allows AWS lambda to create cloduwatch subscription filters, log to cloudwatch and read Firehose delivery stream info"
  policy      = data.aws_iam_policy_document.lambda_cloudwatch_logging.json
}

##########
# IAM Policy Attachments
##########

#### CloudWatch Logs

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_kinesis_firehose_logging" {
  role       = aws_iam_role.cloudwatch_logs_kinesis_firehose_logging.name
  policy_arn = aws_iam_policy.cloudwatch_logs_kinesis_firehose_logging.arn
}

#### Kinesis Data Firehose

resource "aws_iam_role_policy_attachment" "kinesis_firehose_s3_logging" {
  role       = aws_iam_role.kinesis_firehose_s3_logging.name
  policy_arn = aws_iam_policy.kinesis_firehose_s3_logging.arn
}

#### Lambda

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_logging" {
  role       = aws_iam_role.lambda_cloudwatch_logging.name
  policy_arn = aws_iam_policy.lambda_cloudwatch_logging.arn
}
