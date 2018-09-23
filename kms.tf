locals {
  vault_kms_alias = "alias/vault-"
}

resource "aws_kms_key" "vault" {
  description         = "Encryption key for Vault unseal secret"
  is_enabled          = true
  enable_key_rotation = true
}

resource "aws_kms_alias" "vault" {
  name_prefix   = "${local.vault_kms_alias}"
  target_key_id = "${aws_kms_key.vault.arn}"
}
