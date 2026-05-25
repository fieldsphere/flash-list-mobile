#!/usr/bin/env bash
set -euo pipefail

name="${1:-screen}"
max_size="${MAX_SIZE:-1200}"
out_dir=".tmp/agent-device"

mkdir -p "$out_dir"

snapshot_path="${out_dir}/${name}.snapshot.txt"
image_path="${out_dir}/${name}.png"

agent-device snapshot -i | tee "$snapshot_path"

screenshot_args=(screenshot "$image_path" --max-size "$max_size")

if [[ "${OVERLAY_REFS:-}" == "1" || "${OVERLAY_REFS:-}" == "true" ]]; then
  screenshot_args+=(--overlay-refs)
fi

agent-device "${screenshot_args[@]}"

echo "Snapshot: ${snapshot_path}"
echo "Screenshot: ${image_path}"
echo "Read the screenshot PNG with the image-capable file reader before judging visual state."
