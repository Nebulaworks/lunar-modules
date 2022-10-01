variable "env" {
  description = "Name of the environment"
  type        = string
  default     = "dev"
}

variable "s3_logging_bucket" {
  description = "Name of s3 logging bucket"
  type        = string
}

variable "s3_logging_bucket_kms_key_arn" {
  description = "ARN of KMS key that encrypts central logging bucket (optional)"
  type        = string
  default     = ""
}

variable "cloudtrail_log_group_name" {
  description = "Name of log group that a regional cloudtrail writes to"
  type        = string
  default     = "cloudtrail"
}

variable "firehose_log_group_name" {
  description = "Name of log group that the firehose delivery stream will log errors to"
  type        = string
  default     = ""
}

variable "firehose_log_group_retention" {
  description = "Number of days to retain logs for the firehose error log group"
  type        = number
  default     = 180
}

variable "lambda_log_group_name" {
  description = "Name of log group that the central logging lambda will log to"
  type        = string
  default     = ""
}

variable "lambda_log_group_retention" {
  description = "Number of days to retain logs for the lambda log group"
  type        = number
  default     = 180
}

variable "lambda_config" {
  description = "Map of lambda configuration options"
  type = object({
    function_name             = optional(string, "")
    memory_size               = optional(number, 128)
    runtime                   = optional(string, "python3.8")
    s3_package_bucket         = optional(string, "")
    s3_package_prefix         = optional(string, "")
    s3_package_object_version = optional(string, "")
    timeout                   = optional(number, 90)
    vpc_subnet_ids            = optional(list(string), [])
    vpc_security_group_ids    = optional(list(string), [])
  })
}

variable "tags" {
  description = "Map of tags you'd like applied to taggable resources in this module"
  type        = map(string)
  default     = {}
}
