#!/usr/bin/env bash
set -euo pipefail

: "${JENKINS_HOST:?Set JENKINS_HOST}"
: "${JENKINS_USER:?Set JENKINS_USER}"
: "${PI_HOST:?Set PI_HOST}"
: "${PI_USER:?Set PI_USER}"
: "${SSH_KEY_PATH:?Set SSH_KEY_PATH}"

root="$(cd "$(dirname "$0")/.." && pwd)"
tf="$root/terraform/envs/prod"
inventory="$root/ansible/inventory/hosts.ini"

app1="$(terraform -chdir="$tf" output -raw app1_public_ip)"
app2="$(terraform -chdir="$tf" output -raw app2_public_ip)"
app3="$(terraform -chdir="$tf" output -raw app3_public_ip)"
lb="$(terraform -chdir="$tf" output -raw lb_public_ip)"

cat > "$inventory" <<EOF
[jenkins_local]
jenkins ansible_host=$JENKINS_HOST ansible_user=$JENKINS_USER

[minio]
jenkins

[monitoring]
raspberrypi ansible_host=$PI_HOST ansible_user=$PI_USER

[jenkins_agents]

[k3s_server]
app1 ansible_host=$app1 ansible_user=ubuntu

[k3s_agents]
app2 ansible_host=$app2 ansible_user=ubuntu
app3 ansible_host=$app3 ansible_user=ubuntu

[k3s:children]
k3s_server
k3s_agents

[local:children]
jenkins_local
monitoring

[all:vars]
ansible_ssh_private_key_file=$SSH_KEY_PATH
ansible_python_interpreter=/usr/bin/python3
app_domain=$lb
EOF

echo "$lb" > "$root/ingress_ip"
echo "lb_public_ip=$lb"
