---
name: android-emulator
description: Use when validating FlashList fixture behavior, checking emulator or device UI state, capturing visual proof, or debugging Android screen interactions after the app is runnable by package name.
manual-invocation: true
---

# Android Emulator

Use this skill to inspect an Android emulator or device app through accessibility text and visual screenshots. It assumes the app is already installed or runnable by package name, Metro is running when the app needs a JS bundle, and `adb` sees a booted emulator or connected device. Use [start-android-emulator](../start-android-emulator/SKILL.md) first for boot, Metro, TypeScript watch, or `run-android` concerns.

## Core Loop

Run only the steps you need:

```
Validation Progress:
- [ ] Prepare a unique agent-device session (set ANDROID_SERIAL when multiple devices are connected)
- [ ] Open the app
- [ ] Optionally start per-session logs
- [ ] Capture snapshot text and screenshot image
- [ ] Read the screenshot PNG with the image-capable file reader
- [ ] Act through fresh snapshot refs
- [ ] Re-capture text and image proof
- [ ] Stop logs and capture the log path when used
```

## Quick Commands

Install `agent-device` if it is missing:

```bash
npm install -g agent-device@latest
```

When more than one Android device or emulator is connected, pick a serial first:

```bash
adb devices
export ANDROID_SERIAL="emulator-5554"
```

Prepare the session from repo root (source in the same shell used for later commands):

```bash
source .cursor/skills/android-emulator/scripts/setup-session.sh
```

Open the app:

```bash
.cursor/skills/android-emulator/scripts/open-app.sh
```

Optionally start per-session app logs before reproducing:

```bash
agent-device logs start
agent-device logs mark "before validation"
```

Capture current text and screenshot:

```bash
.cursor/skills/android-emulator/scripts/capture-screen.sh screen
```

Immediately read `.tmp/agent-device/screen.png` with the image-capable file reader before judging visual state. The file path alone is not evidence.

Act through refs from the latest `agent-device snapshot -i`, then re-capture:

```bash
agent-device press @e1
agent-device fill @e2 "text"
.cursor/skills/android-emulator/scripts/capture-screen.sh after
```

Read `.tmp/agent-device/after.png` before deciding whether the action worked.

If logs were started, stop them and record where they were written:

```bash
agent-device logs mark "after validation"
agent-device logs stop
agent-device logs path
```

## Guidance

- Prefer `snapshot -i` for labels, buttons, text values, and stable interaction refs.
- If screenshots show a blank screen or a React Native RedBox saying "Unable to load script", switch to [start-android-emulator](../start-android-emulator/SKILL.md) to start Metro on 8081, then reload and re-capture.
- Use screenshots for layout, visual regressions, blank screens, clipping, loading states, and proof.
- Use per-session logs only when diagnosing app/runtime behavior around a repro. Mark before and after the action so the useful log window is easy to find.
- Re-snapshot after each navigation, modal, keyboard change, or scroll before using refs again.
- Capture proof at the end: the final `snapshot -i` output plus a screenshot PNG that has been read visually.
- Set `ANDROID_SERIAL` when multiple Android targets are connected; `setup-session.sh` fails fast in that case without it.
- Keep build, install, Metro, and emulator-boot workflow in [start-android-emulator](../start-android-emulator/SKILL.md); this skill is for observe-act-verify once the app is runnable.
- For direct commands, serial targeting, activity override, relaunch, and overlay refs, see [commands.md](commands.md).
