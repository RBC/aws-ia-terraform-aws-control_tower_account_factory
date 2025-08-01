# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
##############################################################
# CodeCommit - account-request
##############################################################

resource "aws_codepipeline" "codecommit_account_request" {
  count         = local.vcs.is_codecommit ? 1 : 0
  name          = "ct-aft-account-request"
  role_arn      = aws_iam_role.account_request_codepipeline_role.arn
  pipeline_type = "V2"

  artifact_store {
    location = var.codepipeline_s3_bucket_name
    type     = "S3"

    encryption_key {
      id   = var.aft_kms_key_arn
      type = "KMS"
    }
  }

  ##############################################################
  # Source
  ##############################################################
  stage {
    name = "Source"

    action {
      name             = "account-request"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["account-request"]

      configuration = {
        RepositoryName       = var.account_request_repo_name
        BranchName           = var.account_request_repo_branch
        PollForSourceChanges = false
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  ##############################################################
  # Apply Account Request
  ##############################################################
  stage {
    name = "terraform-apply"

    action {
      name             = "Apply-Terraform"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["account-request"]
      output_artifacts = ["account-request-terraform"]
      version          = "1"
      run_order        = "2"
      configuration = {
        ProjectName = aws_codebuild_project.account_request.name
      }
    }
  }
}

# Trigger Pipeline on Commit
resource "aws_cloudwatch_event_rule" "account_request" {
  count       = local.vcs.is_codecommit ? 1 : 0
  name        = "aft-account-request-codepipeline-trigger"
  description = "Trigger CodePipeline upon commit"

  event_pattern = <<EOF
{
  "source": [
    "aws.codecommit"
  ],
  "detail-type": [
    "CodeCommit Repository State Change"
  ],
  "resources": [
    "${aws_codecommit_repository.account_request[0].arn}"
  ],
  "detail": {
    "event": [
      "referenceCreated",
      "referenceUpdated"
    ],
    "referenceType": [
      "branch"
    ],
    "referenceName": [
      "${var.account_request_repo_branch}"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "account_request" {
  count     = local.vcs.is_codecommit ? 1 : 0
  target_id = "codepipeline"
  rule      = aws_cloudwatch_event_rule.account_request[0].name
  arn       = aws_codepipeline.codecommit_account_request[0].arn
  role_arn  = aws_iam_role.cloudwatch_events_codepipeline_role[0].arn
}

##############################################################
# CodeConnections - account-request
##############################################################

moved {
  from = aws_codepipeline.codestar_account_request
  to   = aws_codepipeline.codeconnections_account_request
}

resource "aws_codepipeline" "codeconnections_account_request" {
  count         = local.vcs.is_codecommit ? 0 : 1
  name          = "ct-aft-account-request"
  role_arn      = aws_iam_role.account_request_codepipeline_role.arn
  pipeline_type = "V2"

  artifact_store {
    location = var.codepipeline_s3_bucket_name
    type     = "S3"

    encryption_key {
      id   = var.aft_kms_key_arn
      type = "KMS"
    }
  }

  ##############################################################
  # Source
  ##############################################################
  stage {
    name = "Source"

    action {
      name             = "account-request"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["account-request"]

      configuration = {
        ConnectionArn        = lookup({ github = local.connection_arn.github, bitbucket = local.connection_arn.bitbucket, githubenterprise = local.connection_arn.githubenterprise, gitlab = local.connection_arn.gitlab, gitlabselfmanaged = local.connection_arn.gitlabselfmanaged }, var.vcs_provider)
        FullRepositoryId     = var.account_request_repo_name
        BranchName           = var.account_request_repo_branch
        DetectChanges        = true
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  ##############################################################
  # Apply Account Request
  ##############################################################
  stage {
    name = "terraform-apply"

    action {
      name             = "Apply-Terraform"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["account-request"]
      output_artifacts = ["account-request-terraform"]
      version          = "1"
      run_order        = "2"
      configuration = {
        ProjectName = aws_codebuild_project.account_request.name
      }
    }
  }
}

##############################################################
# CodeCommit - account-provisioning-customizations
##############################################################

resource "aws_codepipeline" "codecommit_account_provisioning_customizations" {
  count         = local.vcs.is_codecommit ? 1 : 0
  name          = "ct-aft-account-provisioning-customizations"
  role_arn      = aws_iam_role.account_provisioning_customizations_codepipeline_role.arn
  pipeline_type = "V2"

  artifact_store {
    location = var.codepipeline_s3_bucket_name
    type     = "S3"

    encryption_key {
      id   = var.aft_kms_key_arn
      type = "KMS"
    }
  }

  ##############################################################
  # Source
  ##############################################################
  stage {
    name = "Source"

    action {
      name             = "account-provisioning-customizations"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["account-provisioning-customizations"]

      configuration = {
        RepositoryName       = var.account_provisioning_customizations_repo_name
        BranchName           = var.account_provisioning_customizations_repo_branch
        PollForSourceChanges = false
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  ##############################################################
  # Account Provisioning Customizations - Terraform Apply
  ##############################################################
  stage {
    name = "terraform-apply"

    action {
      name             = "Apply-Terraform"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["account-provisioning-customizations"]
      output_artifacts = ["account-provisioning-customizations-output"]
      version          = "1"
      run_order        = "2"
      configuration = {
        ProjectName = aws_codebuild_project.account_provisioning_customizations_pipeline.name
      }
    }
  }
}

##############################################################
# CodeConnections - account-provisioning-customizations
##############################################################

moved {
  from = aws_codepipeline.codestar_account_provisioning_customizations
  to   = aws_codepipeline.codeconnections_account_provisioning_customizations
}
resource "aws_codepipeline" "codeconnections_account_provisioning_customizations" {
  count         = local.vcs.is_codecommit ? 0 : 1
  name          = "ct-aft-account-provisioning-customizations"
  role_arn      = aws_iam_role.account_provisioning_customizations_codepipeline_role.arn
  pipeline_type = "V2"

  artifact_store {
    location = var.codepipeline_s3_bucket_name
    type     = "S3"

    encryption_key {
      id   = var.aft_kms_key_arn
      type = "KMS"
    }
  }

  ##############################################################
  # Source
  ##############################################################
  stage {
    name = "Source"

    action {
      name             = "account-provisioning-customizations"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["account-provisioning-customizations"]

      configuration = {
        ConnectionArn        = lookup({ github = local.connection_arn.github, bitbucket = local.connection_arn.bitbucket, githubenterprise = local.connection_arn.githubenterprise, gitlab = local.connection_arn.gitlab, gitlabselfmanaged = local.connection_arn.gitlabselfmanaged }, var.vcs_provider)
        FullRepositoryId     = var.account_provisioning_customizations_repo_name
        BranchName           = var.account_provisioning_customizations_repo_branch
        DetectChanges        = true
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  ##############################################################
  # Account Provisioning Customizations - Terraform Apply
  ##############################################################
  stage {
    name = "terraform-apply"

    action {
      name             = "Apply-Terraform"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["account-provisioning-customizations"]
      output_artifacts = ["account-provisioning-customizations-output"]
      version          = "1"
      run_order        = "2"
      configuration = {
        ProjectName = aws_codebuild_project.account_provisioning_customizations_pipeline.name
      }
    }
  }
}

# Trigger Pipeline on Commit
resource "aws_cloudwatch_event_rule" "account_provisioning_customizations" {
  count       = local.vcs.is_codecommit ? 1 : 0
  name        = "aft-account-provisioning-customizations-trigger"
  description = "Trigger CodePipeline upon commit"

  event_pattern = <<EOF
{
  "source": [
    "aws.codecommit"
  ],
  "detail-type": [
    "CodeCommit Repository State Change"
  ],
  "resources": [
    "${aws_codecommit_repository.account_provisioning_customizations[0].arn}"
  ],
  "detail": {
    "event": [
      "referenceCreated",
      "referenceUpdated"
    ],
    "referenceType": [
      "branch"
    ],
    "referenceName": [
      "${var.account_provisioning_customizations_repo_branch}"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "account_provisioning_customizations" {
  count     = local.vcs.is_codecommit ? 1 : 0
  target_id = "codepipeline"
  rule      = aws_cloudwatch_event_rule.account_provisioning_customizations[0].name
  arn       = aws_codepipeline.codecommit_account_provisioning_customizations[0].arn
  role_arn  = aws_iam_role.cloudwatch_events_codepipeline_role[0].arn
}
