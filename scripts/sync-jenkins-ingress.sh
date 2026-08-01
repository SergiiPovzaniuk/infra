#!/usr/bin/env bash
set -euo pipefail
TF_DIR="$(cd "$(dirname "$0")/../terraform/envs/prod" && pwd)"
IP="$(terraform -chdir="$TF_DIR" output -raw lb_public_ip)"
test -n "$IP"
KEY="${HOME}/.ssh/id_ed25519"
[[ -f "$KEY" ]] || KEY="/mnt/c/Users/sergi/.ssh/id_ed25519"
echo "$IP" | ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -i "$KEY" user@192.168.1.80 \
  "sudo tee /opt/jenkins/ingress_ip >/dev/null && sudo chmod 644 /opt/jenkins/ingress_ip && cat /opt/jenkins/ingress_ip"
echo "ingress_ip=$IP"
