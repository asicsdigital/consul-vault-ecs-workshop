locals {
  env                               = "workshop"
  consul_cluster_size               = "${var.ecs_servers}"
  consul_raft_multiplier            = 5
  consul_sha_htpasswd_hash          = "${var.consul_sha_htpasswd_hash}"
  consul_oauth2_proxy_client_id     = "PLACEHOLDER"
  consul_oauth2_proxy_client_secret = "PLACEHOLDER"
  consul_oauth2_proxy_github_org    = ""
}

module "consul" {
  source                     = "github.com/asicsdigital/terraform-aws-consul-cluster?ref=v7.1.0"
  sha_htpasswd_hash          = "${local.consul_sha_htpasswd_hash}"
  oauth2_proxy_client_id     = "${local.consul_oauth2_proxy_client_id}"
  oauth2_proxy_client_secret = "${local.consul_oauth2_proxy_client_secret}"
  oauth2_proxy_github_org    = "${local.consul_oauth2_proxy_github_org}"
  alb_log_bucket             = "${aws_s3_bucket.consul.id}"
  s3_backup_bucket           = "${aws_s3_bucket.consul.id}"
  cluster_size               = "${local.consul_cluster_size}"
  definitions                = ["ecs-cluster"]
  ecs_cluster_ids            = "${list(module.infra_1.cluster_id, module.infra_2.cluster_id)}"
  env                        = "${local.env}"
  join_ec2_tag_key           = "consul_server"
  join_ec2_tag               = "true"
  subnets                    = "${module.vpc.public_subnets}"
  vpc_id                     = "${module.vpc.vpc_id}"
  raft_multiplier            = "${local.consul_raft_multiplier}"
  enable_script_checks       = true
  region                     = "${local.region}"
}
