---
name: start-android-emulator
description: Starts flash-list Android dev stack on macOS--TypeScript watch, Metro (8081), Android emulator, and the fixture app. Use when the user asks to run the emulator, start Android dev, spin up Metro for Android, fix Android redbox/blank screen from missing Metro, or /start-android-emulator. Requires init-android first on a fresh machine.
disable-model-invocation: true
---

# Start Android Emulator

Spin up the three-process Android dev stack for the FlashList fixture (**FlatListPro**, package `com.flatlistpro`). Run from repo root unless noted.

**Prerequisite:** One-time env via [init-android](../init-android/SKILL.md) (`yarn up`, Node 22.18.0, Yarn Classic, JDK 17, Android SDK, `React-Native-Phone` AVD).

## Environment (every session)

```bash
source ~/.nvm/nvm.sh && nvm use 22.18.0
export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:/opt/homebrew/bin:$PATH"
```

Verify Yarn Classic before starting. If `yarn --version` reports 4.x, run `npm install -g yarn@1.22.22` and `corepack disable`, then open a fresh shell.

## Before Starting

Check what is already running; **do not duplicate** healthy processes.

| Check | Command / signal |
|-------|------------------|
| Metro on 8081 | `lsof -ti:8081` or terminal output `Dev server ready` |
| TS watch | terminal running `yarn build --watch` / `tsc -b --watch` |
| Emulator/device | `adb devices` shows exactly one `device`, or set `ANDROID_SERIAL` |
| App | `adb shell pidof com.flatlistpro`; `agent-device snapshot` shows `com.flatlistpro` |

If Metro is up but the app is stale or timed out, only re-run **Step 4** (run-android) or reload the app with [control-android-emulator](../control-android-emulator/SKILL.md).

## Start Workflow

Copy and track progress:

```
Start Progress:
- [ ] Node 22.18.0 + Android env + Yarn Classic
- [ ] Terminal 1: yarn build --watch (if not running)
- [ ] Terminal 2: Metro in fixture (if 8081 free)
- [ ] Emulator booted and ANDROID_SERIAL selected if needed
- [ ] Terminal 3: run-android -> app launched
```

### Step 1 - TypeScript Watch (repo root)

Skip if already watching. Run in **background** (`block_until_ms: 0`):

```bash
cd <repo-root> && source ~/.nvm/nvm.sh && nvm use 22.18.0 && yarn build --watch
```

### Step 2 - Metro (fixture only)

Skip if port 8081 is in use. Run in **background**:

```bash
cd fixture/react-native && source ~/.nvm/nvm.sh && nvm use 22.18.0 && yarn start
```

Wait until logs show `Dev server ready` or `Welcome to Metro` and verify `curl http://localhost:8081/status` returns `packager-status:running`.

**Do NOT** use root `yarn start` -- RN CLI is not resolved from the fixture's `node_modules`.

### Step 3 - Emulator

If no device is booted, start the default AVD in **background** and wait for boot:

```bash
emulator -avd React-Native-Phone -no-snapshot-load
adb wait-for-device
adb shell getprop sys.boot_completed   # expect 1
```

If multiple Android devices/emulators are connected, set the target serial before running the app:

```bash
adb devices
export ANDROID_SERIAL="emulator-5554"
```

### Step 4 - Build and launch Android app

Run in **background**, then await until `BUILD SUCCESSFUL`, `Installing APK`, or a successful launch line (timeout ~8 min):

```bash
cd fixture/react-native
source ~/.nvm/nvm.sh && nvm use 22.18.0
export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:/opt/homebrew/bin:$PATH"

device_args=()
if [[ -n "${ANDROID_SERIAL:-}" ]]; then
  device_args=(--deviceId "$ANDROID_SERIAL")
fi

yarn react-native run-android --no-packager --active-arch-only "${device_args[@]}"
```

Verify: `adb shell pidof com.flatlistpro` returns a pid, then use [control-android-emulator](../control-android-emulator/SKILL.md) for snapshot/screenshot/log validation.

**Do NOT use `yarn ra` / `yarn fixture:rn:android` for this workflow** -- those scripts do not pass `--no-packager --active-arch-only` and chain `yarn build --watch` after run-android.

## Report To User

Summarize what was already running vs newly started, Metro URL (`http://localhost:8081`), selected Android serial, app id `com.flatlistpro`, and where validation proof was captured if you ran [control-android-emulator](../control-android-emulator/SKILL.md).

## Pitfalls

- `dist/` is not rebuilt on branch switch -- run `yarn build` once if watch was not running.
- Fixture consumes compiled `dist/` -- TS changes need build/watch.
- Android RedBox "Unable to load script" usually means Metro is not running on 8081; start Step 2, then reload with `agent-device press` or re-run Step 4.
- Node 24 + Yarn 4/Corepack can make fixture `yarn start` fail with a lockfile/workspace error; use Node 22.18.0 + Yarn Classic.
- First native build can take several minutes; use JDK 17 and `--active-arch-only` on Apple Silicon.
- Do not kill port 8081 unless the user asks to restart Metro.
- **No `estimatedItemSize`** on FlashList.

## Optional Reload

App connected but blank/redbox after Metro starts: use [control-android-emulator](../control-android-emulator/SKILL.md) to capture refs and press `RELOAD`, or re-run Step 4.
