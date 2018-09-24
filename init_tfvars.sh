#!/bin/bash

var_file=_terraform.auto.tfvars
unseal_key1=CHANGEME
unseal_key2=CHANGEME
unseal_key3=CHANGEME

plaintext="${unseal_key1},${unseal_key2},${unseal_key3}"
kms_alias=$(terraform output -no-color kms_key_alias)
kms_payload=$(aws kms encrypt --key-id "${kms_alias}" --encryption-context purpose=vault_unseal --plaintext "${plaintext}" --output text --query CiphertextBlob)

cat >>"$var_file" <<TFVARS
kms_payload = "${kms_payload}"
initialize_vault = true
TFVARS

cat "$var_file"
