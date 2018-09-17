locals {
  az_count = "${length(local.vpc_azs)}"
  tiers    = ["public", "private", "database", "infra"]
}

provider "aws" {
  region  = "us-east-1"
  version = "~> 1.33"
}

provider "template" {
  version = "~> 1.0"
}

data "aws_availability_zones" "available" {}

data "aws_region" "current" {}
