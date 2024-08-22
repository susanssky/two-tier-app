provider "aws" {}

terraform {
  backend "s3" {
    bucket = "cloud-projects-tfstate"
    key    = "3-two-tier-app-backend.tfstate"
    region = "eu-west-2"
  }
}
