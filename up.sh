#!/bin/bash
set -euo pipefail

YC_CLOUD_ID="b1g7qnf7essotsavp095"
YC_FOLDER_ID="b1g3kp616hdf97f313gj"

terraform -chdir=./terraform/jenkins init -input=false
terraform -chdir=./terraform/k8s init -input=false

terraform -chdir=./terraform/jenkins apply -auto-approve
terraform -chdir=./terraform/k8s apply -auto-approve

JENKINS_IP="$(terraform -chdir=./terraform/jenkins output -raw vm_ip)"
REGISTRY_ID="$(terraform -chdir=./terraform/jenkins output -raw registry_id)"
CLUSTER_ID="$(terraform -chdir=./terraform/k8s output -raw cluster_id)"
KUBECONFIG_FILE="$(pwd)/kubeconfig"

yc managed-kubernetes cluster get-credentials \
    --id "$CLUSTER_ID" \
    --external \
    --force \
    --kubeconfig "$KUBECONFIG_FILE"

cd ./ansible

until ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=5 \
  -i ~/.ssh/diploma "dmitry@${JENKINS_IP}" true; do
  sleep 5
done

ansible-playbook playbooks/setup-jenkins.yml \
    -e @secrets.yml \
    -e "ansible_host=${JENKINS_IP}" \
    -e "yc_registry_id=${REGISTRY_ID}" \
    -e "kubeconfig_src=${KUBECONFIG_FILE}" \
    -e "yc_cloud_id=${YC_CLOUD_ID}" \
    -e "yc_folder_id=${YC_FOLDER_ID}"

cd ..