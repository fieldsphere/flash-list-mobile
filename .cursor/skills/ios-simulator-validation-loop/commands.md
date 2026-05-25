# iOS Simulator Validation Commands

Use these commands only when the compact loop in `SKILL.md` is not enough.

## Environment

Install a published `agent-device` version:

```bash
npm install -g agent-device@latest
```

Default app identifier:

```bash
export BUNDLE_ID="${BUNDLE_ID:-org.reactjs.native.example.FlatListPro}"
```

Use a unique bound session:

```bash
export AGENT_DEVICE_SESSION="ios-sim-${BUNDLE_ID//./-}-$(date +%Y%m%d%H%M%S)"
export AGENT_DEVICE_SESSION_LOCK=reject
```

Target a specific simulator only by passing the UDID explicitly:

```bash
export IOS_SIM_UDID="..."
agent-device open "$BUNDLE_ID" --platform ios --udid "$IOS_SIM_UDID"
```

Do not assume arbitrary environment variables are consumed automatically.

## Direct Observe Commands

Open without relaunching by default:

```bash
agent-device open "$BUNDLE_ID" --platform ios ${IOS_SIM_UDID:+--udid "$IOS_SIM_UDID"}
```

Reserve `--relaunch` for cases where the app is known to be installed and a fresh restart is required:

```bash
agent-device open "$BUNDLE_ID" --platform ios --relaunch ${IOS_SIM_UDID:+--udid "$IOS_SIM_UDID"}
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
OVERLAY_REFS=1 .cursor/skills/ios-simulator-validation-loop/scripts/capture-screen.sh refs
```
