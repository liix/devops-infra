#!/bin/bash
set -euo pipefail

YC_CLOUD_ID="b1g7qnf7essotsavp095"
YC_FOLDER_ID="b1g3kp616hdf97f313gj"

terraform -chdir=./terraform/jenkins init -input=false

terraform -chdir=./terraform/jenkins apply

JENKINS_IP="$(terraform -chdir=./terraform/jenkins output -raw vm_ip)"
REGISTRY_ID="$(terraform -chdir=./terraform/jenkins output -raw registry_id)"
K3S_IP="$(terraform -chdir=./terraform/jenkins output -raw k3s_vm_ip)"
K3S_INTERNAL_IP="$(terraform -chdir=./terraform/jenkins output -raw k3s_vm_internal_ip)"
KUBECONFIG_FILE="$(pwd)/kubeconfig"

cd ./ansible

wait_for_ssh() {
  local host="$1"
  until ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=5 \
    -i ~/.ssh/diploma "ubuntu@${host}" true; do
    sleep 5
  done
}

wait_for_ssh "$JENKINS_IP"
wait_for_ssh "$K3S_IP"

ansible-playbook playbooks/setup-k3s.yml \
    -e "ansible_host=${K3S_IP}" \
    -e "k3s_internal_ip=${K3S_INTERNAL_IP}" \
    -e "kubeconfig_local_path=${KUBECONFIG_FILE}"

ansible-playbook playbooks/setup-jenkins.yml \
    -e @secrets.yml \
    -e "ansible_host=${JENKINS_IP}" \
    -e "yc_registry_id=${REGISTRY_ID}" \
    -e "kubeconfig_src=${KUBECONFIG_FILE}" \
    -e "yc_cloud_id=${YC_CLOUD_ID}" \
    -e "yc_folder_id=${YC_FOLDER_ID}"

cd ..