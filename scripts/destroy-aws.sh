#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../terraform/envs/prod"

ENV_FILE="/mnt/c/Users/sergi/projects/DevOps/.env"
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
AWS_ACCESS_KEY_ID="$(tr -d '\r' <"$ENV_FILE" | sed -n 's/^AWS_ACCESS_KEY_ID=//p')"
AWS_SECRET_ACCESS_KEY="$(tr -d '\r' <"$ENV_FILE" | sed -n 's/^AWS_SECRET_ACCESS_KEY=//p')"
export AWS_EC2_METADATA_DISABLED=true

if [[ -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_SECRET_ACCESS_KEY" ]]; then
  echo "missing AWS credentials in $ENV_FILE" >&2
  exit 1
fi

cp /mnt/c/Users/sergi/projects/DevOps/infra/terraform/envs/prod/terraform.tfvars .
cp /mnt/c/Users/sergi/projects/DevOps/infra/terraform/envs/prod/backend.hcl .

terraform init -reconfigure \
  -backend-config=backend.hcl \
  -backend-config="access_key=examdevops" \
  -backend-config="secret_key=examdevops-minio-change-me"

terraform destroy -auto-approve -var-file=terraform.tfvars
echo "DESTROY_OK"
