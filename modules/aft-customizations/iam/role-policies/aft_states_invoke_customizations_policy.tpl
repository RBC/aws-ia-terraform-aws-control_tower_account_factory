{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": [
                "arn:${data_aws_partition_current_partition}:lambda:${data_aws_region_aft-management_name}:${data_aws_caller_identity_aft-management_account_id}:function:aft-*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "sns:Publish"
            ],
            "Resource": [
                "arn:${data_aws_partition_current_partition}:sns:${data_aws_region_aft-management_name}:${data_aws_caller_identity_aft-management_account_id}:aft-*"
            ]
        }%{ if sns_topic_enable_cmk_encryption },
        {
            "Effect": "Allow",
            "Action": [
                "kms:GenerateDataKey*",
                "kms:Encrypt",
                "kms:Decrypt"
            ],
            "Resource": [
                "${aws_kms_key_aft_arn}"
            ]
       }%{ endif },
        {
            "Effect": "Allow",
            "Action": [
                "events:PutTargets",
                "events:PutRule",
                "events:DescribeRule"
            ],
            "Resource": [
                "arn:${data_aws_partition_current_partition}:events:${data_aws_region_aft-management_name}:${data_aws_caller_identity_aft-management_account_id}:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "states:StartExecution"
            ],
            "Resource": [
                "arn:${data_aws_partition_current_partition}:states:${data_aws_region_aft-management_name}:${data_aws_caller_identity_aft-management_account_id}:stateMachine:aft-*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "states:DescribeExecution",
                "states:StopExecution"
            ],
            "Resource": [
                "arn:${data_aws_partition_current_partition}:states:${data_aws_region_aft-management_name}:${data_aws_caller_identity_aft-management_account_id}:execution:aft-*"
            ]
        }
    ]
}
