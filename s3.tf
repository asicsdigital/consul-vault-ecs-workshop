locals {
  consul_bucket              = "${local.vpc_name}-consul"
  consul_log_policy_resource = "arn:aws:s3:::${local.consul_bucket}/logs/elb/*"
}

data "aws_elb_service_account" "region" {
  region = "${local.region}"
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions = [
      "s3:putObject",
    ]

    resources = [
      "${local.consul_log_policy_resource}",
    ]

    principals = [
      {
        type        = "AWS"
        identifiers = ["${data.aws_elb_service_account.region.arn}"]
      },
    ]
  }
}

resource "aws_s3_bucket" "consul" {
  bucket = "${local.consul_bucket}"
  region = "${local.region}"
  policy = "${data.aws_iam_policy_document.bucket_policy.json}"
}
