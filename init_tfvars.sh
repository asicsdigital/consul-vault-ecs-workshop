#!/bin/bash

var_file=_terraform.auto.tfvars

cat >>"$var_file" <<TFVARS
initialize_vault = true
TFVARS

cat "$var_file"
