# ecs clusters

locals {
  ecs_iam_path              = "/ecs/${local.region}/${var.vpc_name}/"
  infra_allowed_cidr_blocks = ["${distinct(compact(flatten(concat(module.vpc.public_subnets_cidr_blocks, module.vpc.private_subnets_cidr_blocks,module.vpc.intra_subnets_cidr_blocks))))}"]
  ecs_infra_name            = "infra-${local.region}"
}

module "infra_1" {
  source        = "github.com/terraform-community-modules/tf_aws_ecs?ref=v5.4.0"
  name          = "${local.ecs_infra_name}_1"
  key_name      = "${var.ec2_keypair}"
  vpc_id        = "${module.vpc.vpc_id}"
  region        = "${local.region}"
  subnet_id     = ["${module.vpc.private_subnets}"]
  servers       = "${var.ecs_servers}"
  min_servers   = "${min(var.ecs_servers, var.ecs_min_servers)}"
  instance_type = "${var.ecs_instance_type}"
  iam_path      = "${local.ecs_iam_path}"

  extra_tags = [
    {
      key                 = "vpc"
      value               = "${local.vpc_name}"
      propagate_at_launch = true
    },
    {
      key                 = "region"
      value               = "${local.region}"
      propagate_at_launch = true
    },
    {
      key                 = "consul_cluster"
      value               = "primary"
      propagate_at_launch = true
    },
    {
      key                 = "consul_server"
      value               = "true"
      propagate_at_launch = true
    },
  ]
}

module "infra_2" {
  source        = "github.com/terraform-community-modules/tf_aws_ecs?ref=v5.4.0"
  name          = "${local.ecs_infra_name}_2"
  key_name      = "${var.ec2_keypair}"
  vpc_id        = "${module.vpc.vpc_id}"
  region        = "${local.region}"
  subnet_id     = ["${module.vpc.private_subnets}"]
  servers       = "${var.ecs_servers}"
  min_servers   = "${min(var.ecs_servers, var.ecs_min_servers)}"
  instance_type = "${var.ecs_instance_type}"
  iam_path      = "${local.ecs_iam_path}"

  extra_tags = [
    {
      key                 = "vpc"
      value               = "${local.vpc_name}"
      propagate_at_launch = true
    },
    {
      key                 = "region"
      value               = "${local.region}"
      propagate_at_launch = true
    },
    {
      key                 = "consul_cluster"
      value               = "secondary"
      propagate_at_launch = true
    },
    {
      key                 = "consul_server"
      value               = "true"
      propagate_at_launch = true
    },
  ]
}
