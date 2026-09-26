#!/usr/bin/env bash
# Deploy an immutable GHCR image and restore the prior revision on error.
set -euo pipefail

target_image="${1:?target image is required}"
previous_revision="${2:-}"
image_prefix="ghcr.io/zebulon5555/rpi-node-ts-starter:"
compose=(docker compose -p devops-staging -f deploy/compose.staging.yml)

health_ok() {
  curl --fail --silent --show-error http://127.0.0.1:3010/health |
    grep -qx '{"status":"ok"}'
}

deploy_image() {
  local image="$1"
  if ! APP_IMAGE="$image" "${compose[@]}" up -d --pull always --remove-orphans; then
    return 1
  fi
  for _ in $(seq 1 24); do
    if health_ok; then
      APP_IMAGE="$image" "${compose[@]}" ps
      return 0
    fi
    sleep 2
  done
  return 1
}

if deploy_image "$target_image"; then
  exit 0
fi

APP_IMAGE="$target_image" "${compose[@]}" logs --tail=100 || true
if [[ -z "$previous_revision" ]]; then
  echo "Deployment failed and no prior revision is available for rollback." >&2
  exit 1
fi

previous_image="${image_prefix}${previous_revision}"
echo "Deployment failed; restoring $previous_revision" >&2
git checkout --detach --force "$previous_revision"
if deploy_image "$previous_image"; then
  echo "Rollback restored $previous_revision" >&2
else
  APP_IMAGE="$previous_image" "${compose[@]}" logs --tail=100 || true
  echo "Rollback failed." >&2
fi
exit 1
