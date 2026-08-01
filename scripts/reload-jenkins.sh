#!/usr/bin/env bash
set -euo pipefail
JURL=http://127.0.0.1:8080
AUTH=admin:admin-change-me
CK=/tmp/jck
rm -f "$CK"
CRUMB=$(curl -sS -u "$AUTH" -c "$CK" -b "$CK" \
  "$JURL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,%22:%22,//crumb)")
curl -sS -u "$AUTH" -c "$CK" -b "$CK" -X POST -H "$CRUMB" "$JURL/reload" || true
sleep 25
curl -fsS -u "$AUTH" "$JURL/api/json?tree=jobs%5Bname%5D"
echo
curl -sS -o /dev/null -w "infra=%{http_code}\n" -u "$AUTH" "$JURL/job/infra/"
