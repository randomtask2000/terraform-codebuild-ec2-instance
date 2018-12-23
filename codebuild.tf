# Create a new EC2 instance of the latest Ubuntu 14.04 on an
# t2.micro node with an AWS tag naming it "Devbox"

#########################
# variables
#########################
variable "github_personal_access_token" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
variable "public_key" {}
variable "vpc_id" {}
variable "terraform_version" {}

#########################
# providers
#########################
provider "aws" {
  region     = "${var.aws_region}"
}
data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}
data "aws_subnet_ids" "selected" {
  vpc_id = "${data.aws_vpc.selected.id}"
}
#########################
# resources
#########################
resource "aws_s3_bucket" "codebuild_bucket" {
  bucket = "randomtask2000-terraform-state"
  acl    = "private"
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
    # ,
    # {
    #   "Action": [
    #       "ssm:GetParameter"
    #   ],
    #   "Resource": "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/*",
    #   "Effect": "Allow"
    # }
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
    # image        = "aws/codebuild/nodejs:6.3.1"
    image        = "aws/codebuild/ubuntu-base:14.04"
    type         = "LINUX_CONTAINER"
    
    environment_variable {
      "name"  = "GITHUB_PERSONAL_ACCESS_TOKEN"
      "value" = "${var.github_personal_access_token}"
    }

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
      "name"  = "TERRAFORM_VERSION"
      "value" = "0.10.3"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/randomtask2000/terraform_ec2_instance.git"
    git_clone_depth = 1
  }

  # vpc_config {
  #   vpc_id = "${data.aws_vpc.selected.id}"
  #   subnets = ["${data.aws_subnet_ids.selected.ids}"]
  #   security_group_ids = ["${aws_security_group.codebuild_ingress_egress.id}"]
  # }

  tags = {
    group = "codebuild"
  }
}

# see here for VPC issues
# https://stackoverflow.com/questions/52033869/download-source-failed-aws-codebuild
# and buildspec file https://raw.githubusercontent.com/giuseppeborgese/run-terraform-inside-aws-codebuild/master/buildspec.yml 
# and https://github.com/plus3it/terrafirm/blob/master/buildspec.yml
resource "aws_security_group" "codebuild_ingress_egress" {
  name        = "codebuild_ingress_egress"
  description = "Allow cloudbuild with ssh mosh udp http test and egress all"
  vpc_id = "${data.aws_vpc.selected.id}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 60000
    to_port     = 61000
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 0
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 0
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags {
    Name = "cloudbuild"
    group = "cloudbuild"
  }
}

#########################
# outputs
#########################
output "region" {
  value = "${var.aws_region}"
}
output "aws_instance_vpc_id" {
  value = "${var.vpc_id}"
}

output "githubtoken" {
  value = "${var.github_personal_access_token}"
}

output "output_parameter" {
  value = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/*"
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}
