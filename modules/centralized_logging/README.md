<!-- BEGIN_TF_DOCS -->
## Centralized-Logging Module

This module defines resources that enable forwarding of CloudWatch logs (via log groups) within a given account to a central s3 logging bucket. This module is intended to be instantiated in each region.
Log forwarding is achieved via Lambda, CloudWatch, and Kinesis Firehose. A kinesis firehose delivery stream is created with its destination set to an s3 logging bucket of your choice. A lambda function is also created
that creates subscription filters for every log group in your account (except for any cloudtrail log groups). Each subscription filter is configured to foward logs to the delivery stream mentioned above. Any event that gets logged
to a log group will be forwarded to the delivery stream which will then forward the logs to the s3 logging bucket.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.30.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.30.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.cloudwatch_log_group_create](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.lambda_cron](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.cloudwatch_log_group_create](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.lambda_cron](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.firehose_error_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.lambda_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.firehose_error_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_cloudwatch_metric_alarm.lambda_cloudwatch_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_policy.cloudwatch_logs_kinesis_firehose_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.kinesis_firehose_s3_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda_cloudwatch_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.cloudwatch_logs_kinesis_firehose_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.kinesis_firehose_s3_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.lambda_cloudwatch_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_logs_kinesis_firehose_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.kinesis_firehose_s3_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_cloudwatch_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kinesis_firehose_delivery_stream.cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_lambda_function.cloudwatch_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.cloudwatch_lambda_cron](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.cloudwatch_log_create](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_sns_topic.lambda_cloudwatch_logging_errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cloudwatch_logs_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudwatch_logs_kinesis_firehose_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kinesis_firehose_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kinesis_firehose_s3_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_cloudwatch_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudtrail_log_group_name"></a> [cloudtrail\_log\_group\_name](#input\_cloudtrail\_log\_group\_name) | Name of log group that a regional cloudtrail writes to | `string` | `"cloudtrail"` | no |
| <a name="input_cloudwatch_schedule_expression"></a> [cloudwatch\_schedule\_expression](#input\_cloudwatch\_schedule\_expression) | CloudWatch event rule schedule expression that determines when the centralized-logging lambda will run | `string` | `"cron(0 0 * * ? *)"` | no |
| <a name="input_env"></a> [env](#input\_env) | Name of the environment | `string` | `"dev"` | no |
| <a name="input_firehose_delivery_stream_buffer_interval"></a> [firehose\_delivery\_stream\_buffer\_interval](#input\_firehose\_delivery\_stream\_buffer\_interval) | Buffer incoming data to the specified size, in MBs, before delivering it to the destination | `number` | `300` | no |
| <a name="input_firehose_delivery_stream_buffer_size"></a> [firehose\_delivery\_stream\_buffer\_size](#input\_firehose\_delivery\_stream\_buffer\_size) | Buffer incoming data to the specified size, in MBs, before delivering it to the destination | `number` | `5` | no |
| <a name="input_firehose_delivery_stream_compression_format"></a> [firehose\_delivery\_stream\_compression\_format](#input\_firehose\_delivery\_stream\_compression\_format) | The compression format. Some options: 'UNCOMPRESSED', 'GZIP', 'ZIP', 'Snappy', 'HADOOP\_SNAPPY' | `string` | `"GZIP"` | no |
| <a name="input_firehose_delivery_stream_s3_prefix"></a> [firehose\_delivery\_stream\_s3\_prefix](#input\_firehose\_delivery\_stream\_s3\_prefix) | (optional) : The 'YYYY/MM/DD/HH' time format prefix is automatically used for delivered S3 files. You can specify an extra prefix to be added in front of the time format prefix. Note that if the prefix ends with a slash, it appears as a folder in the S3 bucket. <br>  Default prefix defined in data.tf: '<env>/<account\_id>/cloudwatch-logs/' | `string` | `""` | no |
| <a name="input_firehose_log_group_name"></a> [firehose\_log\_group\_name](#input\_firehose\_log\_group\_name) | Name of log group that the firehose delivery stream will log errors to | `string` | `""` | no |
| <a name="input_firehose_log_group_retention"></a> [firehose\_log\_group\_retention](#input\_firehose\_log\_group\_retention) | Number of days to retain logs for the firehose error log group | `number` | `180` | no |
| <a name="input_lambda_config"></a> [lambda\_config](#input\_lambda\_config) | Map of lambda configuration options | `object()` See [variables.tf](variables.tf) for attributes | n/a | yes |
| <a name="input_lambda_log_group_name"></a> [lambda\_log\_group\_name](#input\_lambda\_log\_group\_name) | Name of log group that the central logging lambda will log to | `string` | `""` | no |
| <a name="input_lambda_log_group_retention"></a> [lambda\_log\_group\_retention](#input\_lambda\_log\_group\_retention) | Number of days to retain logs for the lambda log group | `number` | `180` | no |
| <a name="input_s3_logging_bucket"></a> [s3\_logging\_bucket](#input\_s3\_logging\_bucket) | Name of s3 logging bucket | `string` | n/a | yes |
| <a name="input_s3_logging_bucket_kms_key_arn"></a> [s3\_logging\_bucket\_kms\_key\_arn](#input\_s3\_logging\_bucket\_kms\_key\_arn) | ARN of KMS key that encrypts central logging bucket (optional) | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags you'd like applied to taggable resources in this module | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_logs_kinesis_firehose_logging_role_arn"></a> [cloudwatch\_logs\_kinesis\_firehose\_logging\_role\_arn](#output\_cloudwatch\_logs\_kinesis\_firehose\_logging\_role\_arn) | ARN of IAM role used by CloudWatch logs subscription filter to forward logs to Kinesis Data Firhose Delivery stream |
| <a name="output_kinesis_firehose_s3_logging_role_arn"></a> [kinesis\_firehose\_s3\_logging\_role\_arn](#output\_kinesis\_firehose\_s3\_logging\_role\_arn) | ARN of IAM role used by Kinesis Firehose delivery stream to push objects to the s3 logging bucket |
| <a name="output_lambda_cloudwatch_logging_errors_sns_topic"></a> [lambda\_cloudwatch\_logging\_errors\_sns\_topic](#output\_lambda\_cloudwatch\_logging\_errors\_sns\_topic) | ARN of SNS topic for centralized-logging lambda errors |
| <a name="output_lambda_cloudwatch_logging_role_arn"></a> [lambda\_cloudwatch\_logging\_role\_arn](#output\_lambda\_cloudwatch\_logging\_role\_arn) | ARN of IAM role used by centralized-logging lamdba |
<!-- END_TF_DOCS -->
