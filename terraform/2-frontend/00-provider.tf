provider "aws" {}

terraform {
  backend "s3" {
    bucket = "cloud-projects-tfstate"
    key    = "3-two-tier-app-frontend.tfstate"
    region = "eu-west-2"
  }
}
