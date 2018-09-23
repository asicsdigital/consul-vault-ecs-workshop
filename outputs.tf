output "consul_url" {
  value = "${module.consul.consul_url}"
}

output "kms_key_alias" {
  value = "${aws_kms_alias.vault.arn}"
}
