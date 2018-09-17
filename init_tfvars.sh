#!/bin/bash

var_file=_terraform.auto.tfvars
rand_int=$(od -vAn -N2 -tu4 < /dev/urandom | tr -d "[:space:]")
vpc_name="${USER}-${rand_int}"

cat >"$var_file" <<TFVARS
vpc_name = "${vpc_name}"

TFVARS

cat "$var_file"
