#########################
# variables
#########################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
variable "public_key" {}
variable "vpc_id" {}
variable "terraform_version" {}
variable "s3_bucket" {}

variable "destroy_infrastructure_scenario" {
  type = "string"
  default = "false"
}

variable "destroy_infrastructure_scenario_after_build" {
  type = "string"
  default = "false"
}

variable "github_repo_to_be_build" {
  type = "string"
  default = "https://github.com/randomtask2000/terraform_ec2_instance.git"
}

variable "codebuild_image" {
  type = "string"
  default = "aws/codebuild/ubuntu-base:14.04"
}

variable "debug" {
  type = "string"
  default = "true"
}