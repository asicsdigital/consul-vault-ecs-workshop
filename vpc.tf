# vpc

locals {
  region    = "${data.aws_region.current.name}"
  limit_azs = "${length(local.vpc_public_cidrs)}"
  vpc_name  = "${var.vpc_name}-${local.region}"
  vpc_azs   = "${slice(data.aws_availability_zones.available.names, 0, local.limit_azs)}"

  vpc_public_cidrs = [
    "${cidrsubnet(var.vpc_cidr, 8, 1)}",
    "${cidrsubnet(var.vpc_cidr, 8, 2)}",
    "${cidrsubnet(var.vpc_cidr, 8, 3)}",
  ]

  vpc_private_cidrs = [
    "${cidrsubnet(var.vpc_cidr, 8, 10)}",
    "${cidrsubnet(var.vpc_cidr, 8, 20)}",
    "${cidrsubnet(var.vpc_cidr, 8, 30)}",
  ]

  vpc_database_cidrs = [
    "${cidrsubnet(var.vpc_cidr, 8, 101)}",
    "${cidrsubnet(var.vpc_cidr, 8, 102)}",
    "${cidrsubnet(var.vpc_cidr, 8, 103)}",
  ]

  vpc_intra_cidrs = [
    "${cidrsubnet(var.vpc_cidr, 8, 111)}",
    "${cidrsubnet(var.vpc_cidr, 8, 112)}",
    "${cidrsubnet(var.vpc_cidr, 8, 113)}",
  ]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.43.2"

  create_vpc = true

  name = "${local.vpc_name}"
  cidr = "${var.vpc_cidr}"
  azs  = ["${local.vpc_azs}"]

  enable_dns_support      = true
  enable_dns_hostnames    = true
  map_public_ip_on_launch = false

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  public_subnets   = ["${local.vpc_public_cidrs}"]
  private_subnets  = ["${local.vpc_private_cidrs}"]
  database_subnets = ["${local.vpc_database_cidrs}"]
  intra_subnets    = ["${local.vpc_intra_cidrs}"]

  public_subnet_tags = {
    "tier" = "public"
  }

  public_route_table_tags = {
    "tier" = "public"
  }

  private_subnet_tags = {
    "tier" = "private"
  }

  private_route_table_tags = {
    "tier" = "private"
  }

  database_subnet_tags = {
    "tier" = "database"
  }

  intra_subnet_tags = {
    "tier" = "intra"
  }

  intra_route_table_tags = {
    "tier" = "intra"
  }

  create_database_subnet_group = true

  tags {
    region = "${data.aws_region.current.name}"
  }

  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true
}
