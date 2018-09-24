#!/bin/bash

var_file=_terraform.auto.tfvars
unseal_key1=$1
unseal_key2=$2
unseal_key3=$3

if [[ -z "$unseal_key1" || -z "$unseal_key2" || -z "$unseal_key3" ]]; then
  echo "Provide three unseal keys as command-line arguments."
  exit 1
fi

plaintext="${unseal_key1},${unseal_key2},${unseal_key3}"
kms_alias=$(terraform output -no-color kms_key_alias)
kms_payload=$(aws kms encrypt --key-id "${kms_alias}" --encryption-context purpose=vault_unseal --plaintext "${plaintext}" --output text --query CiphertextBlob)

sed -i.bak -e '/initialize_vault/d' $var_file
rm -f "${var_file}.bak"

cat >>"$var_file" <<TFVARS
kms_payload = "${kms_payload}"

TFVARS

cat "$var_file"
