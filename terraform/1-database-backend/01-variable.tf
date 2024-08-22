locals {
  project_name = "two-tier-app"
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    "arn:aws:iam::aws:policy/AWSResourceExplorerReadOnlyAccess",

  ]
  anyone_access_ip = "0.0.0.0/0"
  vpc              = "10.0.0.0/16"
  subnet_number    = 2
}

variable "database_username" {}
variable "database_password" {}
variable "docker_id" {}
variable "docker_token" {}
variable "slack_workspace_id" {}
variable "slack_channel_id" {}


