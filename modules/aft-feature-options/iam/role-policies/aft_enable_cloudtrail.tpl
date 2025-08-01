{
    "Version": "2012-10-17",
    "Statement": [
          {
            "Effect" : "Allow",
            "Action" : "ssm:GetParameter",
            "Resource" : [
                    "arn:${data_aws_partition_current_partition}:ssm:${data_aws_region_current_name}:${data_aws_caller_identity_current_account_id}:parameter/aft/*"
            ]
          },
         {
           "Effect" : "Allow",
           "Action" : [
               "kms:GenerateDataKey*",
               "kms:Encrypt",
               "kms:Decrypt"
           ],
           "Resource" : [
               "${aws_kms_key_aft_arn}"
           ]
         },
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Resource" : [
          "arn:${data_aws_partition_current_partition}:iam::${data_aws_caller_identity_current_account_id}:role/AWSAFTAdmin"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : "sts:GetCallerIdentity",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
            "sns:Publish"
        ],
        "Resource" : [
            "${aws_sns_topic_aft_notifications_arn}",
            "${aws_sns_topic_aft_failure_notifications_arn}"
        ]
      }
    ]
}
