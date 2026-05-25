#!/usr/bin/env bash
set -euo pipefail

BUNDLE_ID="${BUNDLE_ID:-org.reactjs.native.example.FlatListPro}"

args=(open "$BUNDLE_ID" --platform ios)

if [[ -n "${IOS_SIM_UDID:-}" ]]; then
  args+=(--udid "$IOS_SIM_UDID")
fi

if [[ "${RELAUNCH:-}" == "1" || "${RELAUNCH:-}" == "true" ]]; then
  args+=(--relaunch)
fi

agent-device "${args[@]}"
