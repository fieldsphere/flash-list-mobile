---
name: ios-simulator-validation-loop
description: Provides a lightweight observe-act-verify loop for inspecting and interacting with an already installed iOS Simulator app using agent-device snapshots and screenshots. Use when validating FlashList fixture behavior, checking simulator UI state, capturing visual proof, or debugging iOS screen interactions after the app is runnable by bundle ID.
manual-invocation: true
---

# iOS Simulator Validation Loop

Use this skill to inspect an iOS Simulator app through accessibility text and visual screenshots. It assumes the app is already installed or runnable by bundle ID; use [start-ios-simulator](../start-ios-simulator/SKILL.md) for startup, Metro, or build concerns.

## Core Loop

Run only the steps you need:

```
Validation Progress:
- [ ] Prepare a unique agent-device session
- [ ] Open the app
- [ ] Capture snapshot text and screenshot image
- [ ] Read the screenshot PNG with the image-capable file reader
- [ ] Act through fresh snapshot refs
- [ ] Re-capture text and image proof
```

## Quick Commands

Install `agent-device` if it is missing:

```bash
npm install -g agent-device@latest
```

Prepare the session from repo root:

```bash
source .cursor/skills/ios-simulator-validation-loop/scripts/setup-session.sh
```

Open the app:

```bash
.cursor/skills/ios-simulator-validation-loop/scripts/open-app.sh
```

Capture current text and screenshot:

```bash
.cursor/skills/ios-simulator-validation-loop/scripts/capture-screen.sh screen
```

Immediately read `.tmp/agent-device/screen.png` with the image-capable file reader before judging visual state. The file path alone is not evidence.

Act through refs from the latest `agent-device snapshot -i`, then re-capture:

```bash
agent-device press @e1
agent-device fill @e2 "text"
.cursor/skills/ios-simulator-validation-loop/scripts/capture-screen.sh after
```

Read `.tmp/agent-device/after.png` before deciding whether the action worked.

## Guidance

- Prefer `snapshot -i` for labels, buttons, text values, and stable interaction refs.
- Use screenshots for layout, visual regressions, blank screens, clipping, loading states, and proof.
- Re-snapshot after each navigation, modal, keyboard change, or scroll before using refs again.
- Capture proof at the end: the final `snapshot -i` output plus a screenshot PNG that has been read visually.
- Do not add build, install, or simulator-selection workflow to this skill.
- For direct commands, UDID targeting, relaunch, and overlay refs, see [commands.md](commands.md).

