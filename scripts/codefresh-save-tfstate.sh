#!/bin/bash -e

CLUSTER_NAME="${CLUSTER_NAME:-terraform-aks-demo}"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/../

export TFSTATE_BASE64="$(cat terraform/terraform.tfstate | base64 | tr -d '\n')"

sed "s/TFSTATE_BASE64:.*/TFSTATE_BASE64: \"$TFSTATE_BASE64\"/g; s/aks-install/aks-install-$CLUSTER_NAME/g" \
    aks-install-context-template.yaml > aks-install-context.yaml

codefresh patch context -f aks-install-context.yaml
