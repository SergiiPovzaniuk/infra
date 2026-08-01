#!/usr/bin/env bash
set -euo pipefail
JF="${1:-/mnt/c/Users/sergi/projects/DevOps/app-forked/Jenkinsfile}"
fail=0
grep -q "pipeline {" "$JF" || { echo "missing pipeline"; fail=1; }
if grep -q "stage('Terraform')" "$JF"; then
  grep -q "stage('Configure k3s')" "$JF" || { echo "missing Configure k3s"; fail=1; }
  grep -q "terraform apply" "$JF" || { echo "missing terraform apply"; fail=1; }
  grep -q "app-forked/main" "$JF" || { echo "missing app trigger"; fail=1; }
  grep -q "credentials('aws')" "$JF" || { echo "missing aws creds"; fail=1; }
else
  grep -q "stage('Deploy k3s')" "$JF" || { echo "missing Deploy k3s"; fail=1; }
  grep -q 'INGRESS_IP_FILE' "$JF" || { echo "missing INGRESS_IP_FILE"; fail=1; }
  grep -q 'kubectl apply' "$JF" || { echo "missing kubectl apply"; fail=1; }
  grep -q 'envsubst < k8s/app.yaml' "$JF" || { echo "missing envsubst"; fail=1; }
  grep -q 'curl -fsS' "$JF" || { echo "missing ingress curl check"; fail=1; }
  grep -q "branch 'main'" "$JF" || { echo "deploy not gated on main"; fail=1; }
fi
if grep -nE '63\.[0-9]+\.[0-9]+\.[0-9]+|duckdns\.org' "$JF"; then
  echo "hardcoded ingress host/IP found"
  fail=1
fi
if [[ "$fail" -ne 0 ]]; then
  echo "Jenkinsfile validation FAILED"
  exit 1
fi
echo "Jenkinsfile validation OK ($JF)"
