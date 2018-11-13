#!/bin/bash -e

CLIENT_ID="${AZ_CLIENT_ID:-}"
CLIENT_SECRET="${AZ_CLIENT_SECRET:-}"
SUBSCRIPTION_ID="${AZ_SUBSCRIPTION_ID:-}"
TENANT_ID="${AZ_TENANT_ID:-}"


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/../

cd terraform/

echo ${CLIENT_ID}
echo ${TENANT_ID}

terraform init

# try 3 times in case we are stuck waiting for AKS cluster to come up
set +e
N=0
SUCCESS="false"
until [ $N -ge 3 ]; do
  terraform apply -auto-approve \
    -var "client_id=${CLIENT_ID}" \
    -var "client_secret=${CLIENT_SECRET}" \
    -var "subscription_id=${SUBSCRIPTION_ID}" \
    -var "tenant_id=${TENANT_ID}" \
    .
  if [[ "$?" == "0" ]]; then
    SUCCESS="true"
    break
  fi
  N=$[$N+1]
done
set -e

if [[ "$SUCCESS" != "true" ]]; then
    exit 1
fi

terraform output kubeca > ../kubernetes/kubeca.txt
terraform output kubehost > ../kubernetes/kubehost.txt
terraform output kubeconfig > ../kubernetes/kubeconfig.yaml
terraform output config-map-aws-auth > ../kubernetes/config-map-aws-auth.yaml
