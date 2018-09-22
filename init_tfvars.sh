#!/bin/bash

var_file=_terraform.auto.tfvars
rand_int=$(od -vAn -N2 -tu4 < /dev/urandom | tr -d "[:space:]")
sha_hash=$(echo -n "$rand_int" | htpasswd -nis consul)

cat >>"$var_file" <<TFVARS
# password: ${rand_int}
consul_sha_htpasswd_hash = "${sha_hash}"

TFVARS

cat "$var_file"
