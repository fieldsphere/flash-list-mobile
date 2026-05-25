#!/usr/bin/env bash
set -euo pipefail

# Stops Metro, Gradle daemons, and all adb-visible emulators, then boots a fresh AVD.
# Requires ANDROID_HOME + emulator on PATH (source env from SKILL.md first).

AVD_NAME="${AVD_NAME:-React-Native-Phone}"

if [[ -z "${ANDROID_HOME:-}" ]]; then
  echo "ANDROID_HOME is not set. Export it before running this script (see init-android SKILL.md)." >&2
  exit 1
fi

if ! command -v adb >/dev/null 2>&1; then
  echo "adb not found on PATH." >&2
  exit 1
fi

if ! command -v emulator >/dev/null 2>&1; then
  echo "emulator not found on PATH. Add \$ANDROID_HOME/emulator to PATH." >&2
  exit 1
fi

echo "Stopping Metro on port 8081 (if any)..."
lsof -ti:8081 2>/dev/null | xargs kill -9 2>/dev/null || true

repo_root="$(cd "$(dirname "$0")/../../../.." && pwd)"
android_dir="${repo_root}/fixture/react-native/android"
if [[ -f "${android_dir}/gradlew" ]]; then
  echo "Stopping Gradle daemons..."
  (cd "${android_dir}" && ./gradlew --stop) >/dev/null 2>&1 || true
fi

echo "Stopping running emulators..."
while IFS= read -r serial; do
  [[ -z "$serial" ]] && continue
  echo "  adb -s ${serial} emu kill"
  adb -s "$serial" emu kill 2>/dev/null || true
done < <(adb devices 2>/dev/null | awk '/^emulator-/ { print $1 }')

pkill -f "qemu-system" 2>/dev/null || true
pkill -f "emulator.*-avd" 2>/dev/null || true

echo "Restarting adb..."
adb kill-server 2>/dev/null || true
adb start-server

deadline=$((SECONDS + 60))
while [[ "$SECONDS" -lt "$deadline" ]]; do
  if ! adb devices 2>/dev/null | awk 'NR > 1 && $1 ~ /^emulator-/ { found = 1 } END { exit found ? 0 : 1 }'; then
    break
  fi
  sleep 2
done

if ! emulator -list-avds 2>/dev/null | grep -Fxq "$AVD_NAME"; then
  echo "AVD '${AVD_NAME}' not found. Create it per init-android SKILL.md (avdmanager)." >&2
  exit 1
fi

echo "Booting fresh emulator: ${AVD_NAME} (-no-snapshot-load)..."
log_dir="${repo_root}/.tmp/android-emulator"
mkdir -p "$log_dir"
log_path="${log_dir}/${AVD_NAME}.log"

emulator -avd "$AVD_NAME" -no-snapshot-load >"$log_path" 2>&1 &
emu_pid=$!
echo "Emulator log: ${log_path}"

echo "Waiting for device..."
adb wait-for-device

boot_deadline=$((SECONDS + 300))
while [[ "$SECONDS" -lt "$boot_deadline" ]]; do
  if [[ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; then
    break
  fi
  sleep 2
done

if [[ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]]; then
  echo "Emulator did not report sys.boot_completed=1 within 300s (pid ${emu_pid})." >&2
  adb devices
  exit 1
fi

serial="$(adb devices | awk '/^emulator-.*device$/ { print $1; exit }')"
echo "Emulator ready."
adb devices
if [[ -n "$serial" ]]; then
  echo "Suggested: export ANDROID_SERIAL=${serial}"
fi

if [[ "${DETACH_EMULATOR:-}" == "1" || "${DETACH_EMULATOR:-}" == "true" ]]; then
  echo "DETACH_EMULATOR is set; returning while emulator pid ${emu_pid} continues."
  exit 0
fi

echo "Keeping emulator process attached. Leave this terminal running; stop it with Ctrl-C or adb emu kill."
wait "$emu_pid"
