#!/usr/bin/env bash
set -euo pipefail

PACKAGE_NAME="${PACKAGE_NAME:-com.flatlistpro}"
ANDROID_ACTIVITY="${ANDROID_ACTIVITY:-${PACKAGE_NAME}/.MainActivity}"

args=(open "$PACKAGE_NAME" --platform android --activity "$ANDROID_ACTIVITY")

if [[ -n "${ANDROID_SERIAL:-}" ]]; then
  args+=(--serial "$ANDROID_SERIAL")
fi

if [[ "${RELAUNCH:-}" == "1" || "${RELAUNCH:-}" == "true" ]]; then
  args+=(--relaunch)
fi

agent-device "${args[@]}"
