#!/usr/bin/env bash
set -Eeuo pipefail

DEST=/tmp/ComfyWizard
TAR=/tmp/ComfyWizard.tar.gz

if [[ -z "${ARTIFACT_AUTH:-}" ]]; then
  echo "ARTIFACT_AUTH is required. Set it via RunPod Secrets (Basic <base64(user:pass)>)." >&2
  exit 1
fi

# Normalize auth header: accept either raw base64 or full "Basic <base64>"
if [[ "${ARTIFACT_AUTH}" != Basic\ * ]]; then
  ARTIFACT_AUTH="Basic ${ARTIFACT_AUTH}"
fi
export ARTIFACT_AUTH

curl -L https://github.com/MPSimon/ComfyWizard/archive/refs/heads/main.tar.gz -o "$TAR"
mkdir -p "$DEST"
tar -xzf "$TAR" -C "$DEST" --strip-components=1

patch_net_sh() {
  local net_sh="$DEST/lib/net.sh"
  if [[ ! -f "$net_sh" ]]; then
    return 1
  fi
  python - <<'PY'
from pathlib import Path

path = Path("/tmp/ComfyWizard/lib/net.sh")
text = path.read_text()
if "Authorization:" in text:
    raise SystemExit(0)

old = """    if curl -fL --retry 0 -o \"$tmp\" \"$url\"; then\n"""
if old not in text:
    raise SystemExit(1)

new = """    local curl_args=(\"-fL\" \"--retry\" \"0\")\n    if [[ -n \"${ARTIFACT_AUTH:-}\" ]]; then\n      curl_args+=(\"-H\" \"Authorization: ${ARTIFACT_AUTH}\")\n    fi\n    if curl \"${curl_args[@]}\" -o \"$tmp\" \"$url\"; then\n"""
path.write_text(text.replace(old, new))
PY
}

if ! patch_net_sh; then
  echo "Warning: could not patch ComfyWizard downloader to use ARTIFACT_AUTH." >&2
fi

bash "$DEST/bin/wizard.sh"
