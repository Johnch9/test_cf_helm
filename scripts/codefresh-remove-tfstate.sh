#!/bin/bash -e

CLUSTER_NAME="${CLUSTER_NAME:-terraform-aks-demo}"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/../

codefresh delete context aks-install-${CLUSTER_NAME}
