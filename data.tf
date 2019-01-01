#########################
# outputs
#########################

output "region" {
  value = "${var.aws_region}"
}

output "aws_vpc_id" {
  value = "${var.vpc_id}"
}

output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "s3_bucket" {
  value = "${var.s3_bucket}"
}

output "role" {
  value = "${aws_iam_role.codebuild_role.arn}"
}

data "aws_caller_identity" "current" {}

data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}
data "aws_subnet_ids" "selected" {
  vpc_id = "${data.aws_vpc.selected.id}"
}
