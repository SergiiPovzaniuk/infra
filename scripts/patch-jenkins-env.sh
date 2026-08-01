#!/usr/bin/env bash
set -euo pipefail
# run on jenkins host via ssh with env already exported, or pass vault path
ENVF=/opt/jenkins/.env
V="${1:-}"
set_kv() {
  local k="$1" v="$2"
  if grep -q "^${k}=" "$ENVF"; then
    sudo sed -i "s|^${k}=.*|${k}=${v}|" "$ENVF"
  else
    echo "${k}=${v}" | sudo tee -a "$ENVF" >/dev/null
  fi
}
if [[ -n "$V" && -f "$V" ]]; then
  AK=$(sed -n 's/^aws_access_key_id: *"\(.*\)"/\1/p' "$V")
  SK=$(sed -n 's/^aws_secret_access_key: *"\(.*\)"/\1/p' "$V")
  MK=$(sed -n 's/^minio_access_key: *"\(.*\)"/\1/p' "$V")
  MS=$(sed -n 's/^minio_secret_key: *"\(.*\)"/\1/p' "$V")
else
  AK="${AWS_ACCESS_KEY_ID:?}"
  SK="${AWS_SECRET_ACCESS_KEY:?}"
  MK="${MINIO_ACCESS_KEY:?}"
  MS="${MINIO_SECRET_KEY:?}"
fi
set_kv AWS_ACCESS_KEY_ID "$AK"
set_kv AWS_SECRET_ACCESS_KEY "$SK"
set_kv MINIO_ACCESS_KEY "$MK"
set_kv MINIO_SECRET_KEY "$MS"
echo "jenkins env keys patched"
grep -E '^(AWS_|MINIO_)' "$ENVF" | sed 's/=.*/=***/'
