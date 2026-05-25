---
name: init-android
description: Initializes flash-list for Android development on macOS—Node 22, Yarn Classic, ANDROID_HOME, JDK 17, SDK packages, emulator, Gradle, Metro, and run-android. Use when setting up the repo, onboarding, init Android, Android emulator, Gradle, adb, or /init-android.
disable-model-invocation: true
---

# Init Android

One-time and daily workflows for flash-list Android development on macOS. Fork context: `fieldsphere/flash-list-mobile` (from Shopify/flash-list); git remote name `fieldsphere`.

Fixture: React Native **0.84.1**, package **`com.flatlistpro`**, Detox AVD **`React-Native-Phone`** (see `fixture/react-native/.detoxrc.js`).

## /init-android workflow (agents)

When the user invokes `/init-android`, **always** perform a clean slate before checking daily readiness or starting Metro:

1. Export `ANDROID_HOME`, `JAVA_HOME`, and `PATH` (see Environment below).
2. Run `nvm use 22.18.0` and verify Yarn / SDK prerequisites.
3. Run the clean-slate script (stops Metro on 8081, Gradle daemons, all running emulators, then boots a **fresh** `React-Native-Phone` instance with `-no-snapshot-load`).
4. Continue with one-time init items that are still missing, then report daily terminal commands.

Do **not** skip the clean slate because an emulator is already connected — `/init-android` means a brand-new emulator session.

```bash
# after ANDROID_HOME + PATH are set
.cursor/skills/init-android/scripts/clean-slate-and-boot-emulator.sh
```

The script keeps the emulator process attached after boot. Run it in a dedicated long-running terminal (or background shell) and leave that terminal running for the emulator lifetime. Use `DETACH_EMULATOR=1` only for manual local terminal use where process cleanup is not an issue.

Override the AVD name if needed: `AVD_NAME=FlashList35 .cursor/skills/init-android/scripts/clean-slate-and-boot-emulator.sh`

## Prerequisites checklist

- [ ] macOS with enough disk for SDK + emulator (several GB)
- [ ] nvm (or equivalent) for Node **22.18.0**
- [ ] **Yarn Classic 1.22.x** (lockfile v1; disable Corepack if it hijacks `yarn` to v4)
- [ ] **JDK 17** for Gradle (not JDK 25 — breaks Gradle 9 / RN toolchain)
- [ ] Android SDK + platform-tools + emulator

## Version fixes (common blockers)

| Problem | Fix |
|---------|-----|
| Node 24 + Yarn 4 / Corepack | `nvm use 22.18.0`, `npm install -g yarn@1.22.22`, `corepack disable` if `yarn` still resolves to 4.x |
| `ANDROID_HOME` unset / no `adb` | Set `ANDROID_HOME` (Homebrew SDK root below) and extend `PATH` |
| Gradle: `JvmVendorSpec IBM_SEMERU` / JDK 25 | `export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"` (`brew install openjdk@17`) |
| CMake fails / missing `cmake;3.22.1` | `sdkmanager "cmake;3.22.1"` (required by Reanimated/worklets native build) |
| CMake fails on **x86** on Apple Silicon | `npx react-native run-android --active-arch-only` (builds **arm64-v8a** for the arm64 emulator) |
| `Build Tools revision 35.0.0 is corrupted` | Remove `$ANDROID_HOME/build-tools/35.0.0` and any `*-2` duplicate dirs, then `sdkmanager "build-tools;35.0.0"` |
| `error: more than one device/emulator` | `adb devices`, then `run-android --deviceId emulator-5554` (or stop extra emulators) |
| Parallel Gradle daemons / flaky native builds | `./gradlew --stop` then rebuild; prefer `--active-arch-only` on M-series Macs |
| Port 8081 in use | `/init-android` kills Metro on 8081 during clean slate; otherwise check `lsof -ti:8081` before starting Metro |
| Stale emulator / wrong device state | Run `clean-slate-and-boot-emulator.sh` (included in `/init-android`) |

### Environment (Homebrew SDK — verified on this fork)

```bash
export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:/opt/homebrew/bin:$PATH"
```

Install SDK stack (if missing):

```bash
brew install --cask android-commandlinetools android-platform-tools
brew install openjdk@17
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0" "build-tools;35.0.0" \
  "ndk;27.1.12297006" "cmake;3.22.1" "emulator"
sdkmanager "system-images;android-35;google_apis;arm64-v8a"
echo no | avdmanager create avd -n "React-Native-Phone" -k "system-images;android-35;google_apis;arm64-v8a" -d "pixel_6"
```

Repo Android pins (from `fixture/react-native/android/build.gradle`): **compileSdk / targetSdk 36**, **build-tools 36.0.0**, **NDK 27.1.12297006**, **minSdk 24**, **Gradle 9.0.0**, **Kotlin 2.1.20**, **newArchEnabled=true**.

Alternative: Android Studio installs SDK under `~/Library/Android/sdk` — set `ANDROID_HOME` to that path instead.

## One-time init (repo root)

Copy and track progress:

```
Init Progress:
- [ ] Node 22.18.0 active
- [ ] Yarn Classic 1.22.x global (Corepack off if needed)
- [ ] ANDROID_HOME + JDK 17 in shell
- [ ] SDK packages + licenses + React-Native-Phone AVD
- [ ] yarn up (or yarn + fixture deps)
- [ ] agent-device CLI (`npm install -g agent-device@latest`)
```

Commands:

```bash
nvm install 22.18.0 && nvm use 22.18.0
npm install -g yarn@1.22.22 agent-device@latest
# export ANDROID_HOME, JAVA_HOME, PATH (see above)
yarn up
# /init-android: always run after env exports
.cursor/skills/init-android/scripts/clean-slate-and-boot-emulator.sh
```

`yarn up` runs root `yarn`, fixture deps + **iOS** `pod install`, Detox `applesimutils`, `yarn build`. It does **not** install the Android SDK — do that separately.

## Daily dev workflow

For normal daily startup after one-time setup, prefer [start-android-emulator](../start-android-emulator/SKILL.md). Keep the commands below as the underlying manual flow and for `/init-android` clean-slate follow-up.

```
Daily Progress:
- [ ] Clean slate + fresh emulator (required on /init-android)
- [ ] Terminal 1: yarn build --watch
- [ ] Terminal 2: Metro in fixture
- [ ] Terminal 3: run Android app
```

| Terminal | Command |
|----------|---------|
| 1 | `yarn build --watch` |
| 2 | `cd fixture/react-native && yarn start` (Metro on 8081) |
| 3 | `cd fixture/react-native && yarn react-native run-android --no-packager --active-arch-only` (add `--deviceId emulator-5554` if multiple devices) |

From repo root (chains `run-android` then `build --watch` — prefer separate Metro + `build --watch` terminals):

```bash
yarn ra   # alias: yarn fixture:rn:android
```

CONTRIBUTING mentions `yarn run-android`; the root script is **`yarn ra`** (not `run-android`).

Fresh emulator (default for `/init-android`; also use after a bad session):

```bash
.cursor/skills/init-android/scripts/clean-slate-and-boot-emulator.sh
```

Manual boot only when you intentionally want to keep existing Metro/emulator processes:

```bash
emulator -avd React-Native-Phone -no-snapshot-load
adb wait-for-device
adb shell getprop sys.boot_completed   # expect 1
```

**Do NOT use root `yarn start`** — `react-native` CLI is not resolved from the fixture's `node_modules` at the monorepo root. Use `cd fixture/react-native && yarn start`.

## Pitfalls

- Emulator UI validation for agents uses **agent-device** via `.cursor/skills/control-android-emulator/` — install globally with `npm install -g agent-device@latest`; when multiple devices are connected, set `ANDROID_SERIAL` (see `adb devices`) before snapshot/screenshot/log commands
- `dist/` is **not** rebuilt on branch switch — run `yarn build` after checkout
- Fixture consumes compiled `dist/` — TS changes need build/watch
- **No `estimatedItemSize`** on FlashList (prop does not exist in this codebase)
- First native build can take several minutes; use JDK 17 and `--active-arch-only` on Apple Silicon
- Do not commit `Podfile.lock` or local Gradle/SDK artifacts unless intentional
- `brew install --cask temurin@17` may require sudo; **`brew install openjdk@17`** is sufficient for Gradle

## Optional ~/.zshrc

```bash
export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
# in repo: nvm use 22.18.0
```
