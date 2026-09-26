#!/usr/bin/env bash
# Deploy the checked-out revision and restore the previous healthy revision on error.
set -euo pipefail

previous_revision="${1:-}"
compose=(docker compose -p devops-staging -f deploy/compose.staging.yml)

health_ok() {
  curl --fail --silent --show-error http://127.0.0.1:3010/health |
    grep -qx '{"status":"ok"}'
}

deploy_checked_out_revision() {
  "${compose[@]}" up -d --build --remove-orphans
  for _ in $(seq 1 24); do
    if health_ok; then
      "${compose[@]}" ps
      return 0
    fi
    sleep 2
  done
  return 1
}

if deploy_checked_out_revision; then
  exit 0
fi

"${compose[@]}" logs --tail=100 || true
if [[ -z "$previous_revision" ]]; then
  echo "Deployment failed and no prior revision is available for rollback." >&2
  exit 1
fi

echo "Deployment failed; restoring $previous_revision" >&2
git checkout --detach --force "$previous_revision"
if deploy_checked_out_revision; then
  echo "Rollback restored $previous_revision" >&2
else
  "${compose[@]}" logs --tail=100 || true
  echo "Rollback failed." >&2
fi
exit 1
