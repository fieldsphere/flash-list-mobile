# Android Emulator Validation Commands

Use these commands only when the compact loop in `SKILL.md` is not enough.

## Prereqs

- Node.js 22+ and `agent-device` on PATH
- Android SDK Platform-Tools (`adb`) on PATH
- At least one booted emulator or connected device visible in `adb devices`

## Environment

Install a published `agent-device` version:

```bash
npm install -g agent-device@latest
```

Default app identifier and launcher activity:

```bash
export PACKAGE_NAME="${PACKAGE_NAME:-com.flatlistpro}"
export ANDROID_ACTIVITY="${ANDROID_ACTIVITY:-${PACKAGE_NAME}/.MainActivity}"
```

Use a unique bound session:

```bash
export AGENT_DEVICE_SESSION="android-emu-${PACKAGE_NAME//./-}-$(date +%Y%m%d%H%M%S)"
export AGENT_DEVICE_SESSION_LOCK=reject
```

Find serials and target a specific device when more than one is connected:

```bash
adb devices
export ANDROID_SERIAL="emulator-5554"
agent-device open "$PACKAGE_NAME" --platform android --serial "$ANDROID_SERIAL" --activity "$ANDROID_ACTIVITY"
```

Do not assume arbitrary environment variables are consumed automatically.

## Direct Observe Commands

Open without relaunching by default:

```bash
agent-device open "$PACKAGE_NAME" --platform android --activity "$ANDROID_ACTIVITY" ${ANDROID_SERIAL:+--serial "$ANDROID_SERIAL"}
```

Reserve `--relaunch` for cases where the app is known to be installed and a fresh restart is required:

```bash
agent-device open "$PACKAGE_NAME" --platform android --activity "$ANDROID_ACTIVITY" --relaunch ${ANDROID_SERIAL:+--serial "$ANDROID_SERIAL"}
```

Read current screen text and interaction refs:

```bash
agent-device snapshot -i
```

Capture an image:

```bash
mkdir -p .tmp/agent-device
agent-device screenshot ".tmp/agent-device/screen.png" --max-size 1200
```

Always read the PNG with the image-capable file reader before judging layout, clipping, blank screens, loading states, or visual proof.

## Visual Grounding

Capture refs overlaid on the screenshot:

```bash
agent-device screenshot ".tmp/agent-device/refs.png" --max-size 1200 --overlay-refs
```

Or use the helper:

```bash
OVERLAY_REFS=1 .cursor/skills/control-android-emulator/scripts/capture-screen.sh refs
```

## Per-Session Logs

Use app logs when visual state is not enough to explain a repro. Keep the flow
short: start logs, mark the action, reproduce, stop logs, then capture the log
path. On Android, logs route to logcat.

```bash
agent-device logs start
agent-device logs mark "before repro"
# reproduce with snapshot/press/fill/capture commands
agent-device logs mark "after repro"
agent-device logs stop
agent-device logs path
```

If logs may contain stale noise from an earlier run, clear and restart them
before reproducing:

```bash
agent-device logs clear --restart
agent-device logs mark "before repro"
```
