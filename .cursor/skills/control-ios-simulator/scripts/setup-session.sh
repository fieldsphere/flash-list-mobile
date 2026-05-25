#!/usr/bin/env bash

# Source this file so the exported variables remain available to later commands.
export BUNDLE_ID="${BUNDLE_ID:-org.reactjs.native.example.FlatListPro}"

if [[ -z "${AGENT_DEVICE_SESSION:-}" ]]; then
  safe_bundle_id="${BUNDLE_ID//./-}"
  export AGENT_DEVICE_SESSION="ios-sim-${safe_bundle_id}-$(date +%Y%m%d%H%M%S)"
fi

export AGENT_DEVICE_SESSION_LOCK="${AGENT_DEVICE_SESSION_LOCK:-reject}"

echo "BUNDLE_ID=${BUNDLE_ID}"
echo "AGENT_DEVICE_SESSION=${AGENT_DEVICE_SESSION}"
echo "AGENT_DEVICE_SESSION_LOCK=${AGENT_DEVICE_SESSION_LOCK}"

if [[ -n "${IOS_SIM_UDID:-}" ]]; then
  echo "IOS_SIM_UDID=${IOS_SIM_UDID} (will be passed explicitly by open-app.sh)"
fi
