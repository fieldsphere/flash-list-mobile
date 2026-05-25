#!/usr/bin/env bash

# Source this file so the exported variables remain available to later commands.
export PACKAGE_NAME="${PACKAGE_NAME:-com.flatlistpro}"
export ANDROID_ACTIVITY="${ANDROID_ACTIVITY:-${PACKAGE_NAME}/.MainActivity}"

if [[ -z "${AGENT_DEVICE_SESSION:-}" ]]; then
  safe_package="${PACKAGE_NAME//./-}"
  export AGENT_DEVICE_SESSION="android-emu-${safe_package}-$(date +%Y%m%d%H%M%S)"
fi

export AGENT_DEVICE_SESSION_LOCK="${AGENT_DEVICE_SESSION_LOCK:-reject}"

count_android_devices() {
  adb devices 2>/dev/null | awk 'NR > 1 && $2 == "device" { print $1 }' | wc -l | tr -d ' '
}

device_count="$(count_android_devices)"

if [[ -z "${ANDROID_SERIAL:-}" ]]; then
  if [[ "${device_count}" -gt 1 ]]; then
    echo "Multiple Android devices/emulators are connected (${device_count})." >&2
    echo "Set ANDROID_SERIAL to the target serial from: adb devices" >&2
    exit 1
  fi
  if [[ "${device_count}" -eq 0 ]]; then
    echo "No Android device/emulator found. Boot an emulator or connect a device, then run: adb devices" >&2
    exit 1
  fi
  echo "ANDROID_SERIAL is not set; using the single connected device from adb."
  echo "If you add another device, set ANDROID_SERIAL=<serial> before sourcing this script."
else
  echo "ANDROID_SERIAL=${ANDROID_SERIAL} (will be passed explicitly by open-app.sh)"
fi

echo "PACKAGE_NAME=${PACKAGE_NAME}"
echo "ANDROID_ACTIVITY=${ANDROID_ACTIVITY}"
echo "AGENT_DEVICE_SESSION=${AGENT_DEVICE_SESSION}"
echo "AGENT_DEVICE_SESSION_LOCK=${AGENT_DEVICE_SESSION_LOCK}"
