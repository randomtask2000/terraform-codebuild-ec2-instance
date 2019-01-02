# Create an AWS CodeBuild project

#########################
# providers
#########################
provider "aws" {
  region     = "${var.aws_region}"
}

#########################
# resources
#########################
resource "aws_s3_bucket" "codebuild_bucket" {
  bucket = "${var.s3_bucket}"
  acl    = "private"
  force_destroy = true
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action":["s3:GetObject", "s3:DeleteObject"],
      "Resource":["arn:aws:s3:::${var.s3_bucket}", "arn:aws:s3:::${var.s3_bucket}/*"],
      "Principal": { "AWS": "${aws_iam_role.codebuild_role.arn}" }
    }
  ]
}
EOF
  tags = {
    group = "codebuild"
  }
}

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = {
    group = "codebuild"
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role = "${aws_iam_role.codebuild_role.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": ["ec2:*"],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.codebuild_bucket.arn}",
        "${aws_s3_bucket.codebuild_bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "ssm:GetParameter",
        "ssm:GetParametersByPath"
      ],
      "Resource": "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/*",
      "Effect": "Allow"
    }

  ]
}
POLICY
}

resource "aws_codebuild_project" "codebuild_project" {
  name          = "codebuild-project"
  description   = "Codebuild Project that builds a github repo"
  build_timeout = "15"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = "${aws_s3_bucket.codebuild_bucket.bucket}"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "${var.codebuild_image}"
    type         = "LINUX_CONTAINER"

    environment_variable {
      "name"  = "AWS_ACCESS_KEY"
      "value" = "${var.aws_access_key}"
    }

    environment_variable {
      "name"  = "AWS_SECRET_KEY"
      "value" = "${var.aws_secret_key}"
    }

    environment_variable {
      "name"  = "AWS_REGION"
      "value" = "${var.aws_region}"
    }

    environment_variable {
      "name"  = "PUBLIC_KEY"
      "value" = "${var.public_key}"
    }

    environment_variable {
      "name"  = "VPC_ID"
      "value" = "${var.vpc_id}"
    }

    environment_variable {
      "name"  = "S3_BUCKET"
      "value" = "${var.s3_bucket}"
    }

    environment_variable {
      "name" = "DESTROY"
      "value" = "${var.destroy_infrastructure_scenario}"
    }

    environment_variable {
      "name"  = "DESTROY_AFTER_APPLY"
      "value" = "${var.destroy_infrastructure_scenario_after_build}"
    }

    environment_variable {
      "name"  = "DEBUG"
      "value" = "${var.debug}"
    }
  }

  source {
    type            = "GITHUB"
    location        = "${var.github_repo_to_be_build}"
    git_clone_depth = 1
  }

  tags = {
    group = "codebuild"
  }
}