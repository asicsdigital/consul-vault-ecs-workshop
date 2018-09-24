locals {
  vault_image      = "vault:0.11.1"
  initialize_vault = "${var.initialize_vault ? true : false}"
}

data "aws_kms_secrets" "secrets" {
  secret {
    name    = "vault_unseal_key"
    payload = "${var.kms_payload}"

    context {
      purpose = "vault_unseal"
    }
  }
}

module "vault" {
  source          = "github.com/asicsdigital/terraform-aws-vault?ref=v1.3.0"
  alb_log_bucket  = "${local.consul_bucket}"
  vault_image     = "${local.vault_image}"
  ecs_cluster_ids = "${list(module.infra_1.cluster_id, module.infra_2.cluster_id)}"
  env             = "${local.env}"
  subnets         = "${module.vpc.public_subnets}"
  unseal_keys     = "${split(",", data.aws_kms_secrets.secrets.plaintext["vault_unseal_key"])}"
  vpc_id          = "${module.vpc.vpc_id}"
  initialize      = "${local.initialize_vault}"
}
