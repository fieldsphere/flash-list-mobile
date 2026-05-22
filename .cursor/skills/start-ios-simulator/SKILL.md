---
name: start-ios-simulator
description: Starts flash-list iOS dev stack on macOS—TypeScript watch, Metro (8081), and fixture app on the iOS Simulator. Use when the user asks to run the simulator, start iOS dev, spin up Metro, or /start-ios-simulator. Requires init-ios-setup first on a fresh machine.
disable-model-invocation: true
---

# Start iOS Simulator

Spin up the three-process iOS dev stack for `fieldsphere/flash-list-mobile` (fixture: **FlatListPro**). Run from repo root unless noted.

**Prerequisite:** One-time env via [init-ios-setup](../init-ios-setup/SKILL.md) (`yarn up`, Node 22.18.0, Yarn Classic, Ruby 3.3).

## Environment (every session)

```bash
source ~/.nvm/nvm.sh && nvm use 22.18.0
export PATH="/opt/homebrew/opt/ruby@3.3/bin:/opt/homebrew/lib/ruby/gems/3.3.0/bin:$PATH"
```

## Before starting

Check what is already running; **do not duplicate** healthy processes.

| Check | Command / signal |
|-------|------------------|
| Metro on 8081 | `lsof -ti:8081` or terminal output `Dev server ready` |
| TS watch | terminal running `yarn build --watch` / `tsc -b --watch` |
| Simulator + app | `xcrun simctl list devices booted`; Metro logs mention `FlatListPro` |

If Metro is up but the app is stale or timed out, only re-run **Step 3** (run-ios).

## Start workflow

Copy and track progress:

```
Start Progress:
- [ ] Node 22.18.0 + Ruby PATH
- [ ] Terminal 1: yarn build --watch (if not running)
- [ ] Terminal 2: Metro in fixture (if 8081 free)
- [ ] Terminal 3: run-ios → simulator booted
```

### Step 1 — TypeScript watch (repo root)

Skip if already watching. Run in **background** (`block_until_ms: 0`):

```bash
cd <repo-root> && source ~/.nvm/nvm.sh && nvm use 22.18.0 && yarn build --watch
```

### Step 2 — Metro (fixture only)

Skip if port 8081 is in use. Run in **background**:

```bash
cd fixture/react-native && source ~/.nvm/nvm.sh && nvm use 22.18.0 && yarn start
```

Wait until logs show `Dev server ready` (poll terminal output).

**Do NOT** use root `yarn start` — RN CLI is not resolved from the fixture's `node_modules`.

### Step 3 — Build and launch iOS app

Run in **background**, then **await** until `Successfully launched` or `BUILD SUCCEEDED` (timeout ~5 min):

```bash
cd fixture/react-native && source ~/.nvm/nvm.sh && nvm use 22.18.0 && \
  export PATH="/opt/homebrew/opt/ruby@3.3/bin:/opt/homebrew/lib/ruby/gems/3.3.0/bin:$PATH" && \
  yarn react-native run-ios
```

Verify: `xcrun simctl list devices booted` shows a device (e.g. iPhone 17 Pro).

**Do NOT use `yarn ri` / `yarn fixture:rn:ios` for this workflow** — those scripts chain `yarn build --watch` after run-ios and are wrong for starting the stack.

## Report to user

Summarize what was already running vs newly started, Metro URL (`http://localhost:8081`), booted simulator name, and app id `org.reactjs.native.example.FlatListPro`.

## Pitfalls

- `dist/` is not rebuilt on branch switch — run `yarn build` once if watch was not running
- Metro device timeout errors → re-run Step 3 only; Metro can stay up
- Do not kill port 8081 unless the user asks to restart Metro
- **No `estimatedItemSize`** on FlashList

## Optional reload

App connected but blank/redbox: in Simulator press **Cmd+R**, or restart Step 3.
