# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
variable "aft_vpc_private_subnets" {
  type    = list(string)
  default = null
}

variable "aft_vpc_default_sg" {
  type    = list(string)
  default = null
}

variable "aft_common_layer_arn" {
  type = string
}

variable "cloudwatch_log_group_retention" {
  type = string
}

variable "cloudwatch_log_group_enable_cmk_encryption" {
  type = bool
}

variable "sns_topic_enable_cmk_encryption" {
  type = bool
}

variable "aft_kms_key_arn" {
  type = string
}

variable "aft_kms_key_id" {
  type = string
}

variable "aft_sns_topic_arn" {
  type = string
}

variable "aft_failure_sns_topic_arn" {
  type = string
}

variable "log_archive_bucket_name" {
  type = string
}

variable "log_archive_access_logs_bucket_name" {
  type = string
}

variable "log_archive_bucket_object_expiration_days" {
  type = number
}

variable "log_archive_account_id" {
  type = string
}

variable "aft_features_sfn_name" {
  type = string
}
variable "feature_options_archive_path" {
  type = string
}

variable "feature_options_archive_hash" {
  type = string
}

variable "delete_default_vpc_lambda_function_name" {
  type = string
}

variable "enroll_support_lambda_function_name" {
  type = string
}

variable "enable_cloudtrail_lambda_function_name" {
  type = string
}

variable "lambda_runtime_python_version" {
  type = string
}

variable "aft_enable_vpc" {
  type = bool

}
