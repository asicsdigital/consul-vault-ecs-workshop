# route 53

locals {
  fqdn = "${local.vpc_name}.test"
}

resource "aws_route53_zone" "zone" {
  name = "${local.fqdn}"

  tags {
    vpc = "${local.vpc_name}"
  }
}
