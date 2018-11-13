#!/bin/bash -e

CLIENT_CERTIFICATE="${AZ_CLIENT_CERTIFICATE:-}"
CLIENT_KEY="${AZ_CLIENT_KEY:-}"
TOKEN="${AZ_TOKEN:-}"
CLUSTER_CA_CERTIFICATE="${AZ_CLUSTER_CA_CERTIFICATE:-}"


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
    -var "client_certificate=${CLIENT_CERTIFICATE}" \
    -var "client_key=${CLIENT_KEY}" \
    -var "token=${TOKEN}" \
    -var "cluster_ca_certificate=${CLUSTER_CA_CERTIFICATE}" \
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
