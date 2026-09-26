#!/usr/bin/env bash
# Expose Pi2 staging only on this machine through the existing NetBird SSH path.
set -euo pipefail

local_port="${LOCAL_PORT:-3010}"
remote_host="${STAGING_SSH_HOST:-pi2.netbird.cloud}"
remote_user="${STAGING_SSH_USER:-pi}"

printf 'Pi2 staging tunnel: http://127.0.0.1:%s\n' "$local_port"
exec ssh \
  -o BatchMode=yes \
  -o ExitOnForwardFailure=yes \
  -o ServerAliveInterval=30 \
  -o ServerAliveCountMax=3 \
  -N \
  -L "127.0.0.1:${local_port}:127.0.0.1:3010" \
  "${remote_user}@${remote_host}"
