---
name: init-ios
description: Initializes flash-list for iOS development on macOS—Node 22, Yarn Classic, Ruby 3.3, bundle install, yarn up, CocoaPods, Metro, and simulator. Use when setting up the repo, onboarding, init iOS, first-time dev environment, or /init-ios.
disable-model-invocation: true
---

# Init iOS

One-time and daily workflows for flash-list iOS development on macOS. Fork context: `fieldsphere/flash-list-mobile` (from Shopify/flash-list); git remote name `fieldsphere`.

## Prerequisites checklist

- [ ] macOS with Xcode and iOS Simulator (`xcode-select -p`, `xcodebuild -version`)
- [ ] nvm (or equivalent) for Node **22.18.0** (CI/project standard)
- [ ] Homebrew if system Ruby is 2.6.x (need Ruby 3.3 for Bundler/CocoaPods)
- [ ] `agent-device` CLI (for [ios-simulator](../ios-simulator/SKILL.md))

## Version fixes (common blockers)

| Problem | Fix |
|---------|-----|
| Node 24 + Yarn 4 | Project needs **Node 22.18.0** and **Yarn Classic 1.22.x** (lockfile v1) |
| System Ruby 2.6 | `brew install ruby@3.3`, prepend PATH (see below) |
| `.ruby-version` | Says 3.3.1; Homebrew `ruby@3.3` is fine |

Ruby PATH (when needed):

```bash
export PATH="/opt/homebrew/opt/ruby@3.3/bin:/opt/homebrew/lib/ruby/gems/3.3.0/bin:$PATH"
```

## One-time init (repo root)

Copy and track progress:

```
Init Progress:
- [ ] Node 22.18.0 active
- [ ] Yarn Classic 1.22.x global
- [ ] Ruby 3.3 on PATH (if needed)
- [ ] bundle install
- [ ] yarn up
- [ ] agent-device installed globally
```

Commands:

```bash
nvm install 22.18.0 && nvm use 22.18.0
npm install -g yarn@1.22.22
export PATH="/opt/homebrew/opt/ruby@3.3/bin:/opt/homebrew/lib/ruby/gems/3.3.0/bin:$PATH"  # if needed
bundle install
yarn up
npm install -g agent-device@latest
```

`yarn up` runs: root `yarn`, fixture deps + `pod install`, `applesimutils` (Detox e2e), `yarn build`.

`agent-device` is the snapshot/screenshot CLI used by the `ios-simulator` skill to inspect and drive the running simulator. Verify with `which agent-device`.

## Daily dev workflow

```
Daily Progress:
- [ ] Terminal 1: yarn build --watch
- [ ] Terminal 2: Metro in fixture
- [ ] Terminal 3: run iOS app
```

| Terminal | Command |
|----------|---------|
| 1 | `yarn build --watch` |
| 2 | `cd fixture/react-native && yarn start` (Metro on 8081) |
| 3 | `cd fixture/react-native && yarn react-native run-ios` — or from root: `yarn ri` / `yarn fixture:rn:ios` |

**Do NOT use root `yarn start`** — `react-native` CLI is not resolved from fixture's `node_modules`.

## Pitfalls

- `dist/` is **not** rebuilt on branch switch — run `yarn build` after checkout
- Fixture consumes compiled `dist/` — TS changes need build/watch
- Native/pod changes: `cd fixture/react-native/ios && bundle exec pod install`, then rebuild app
- **No `estimatedItemSize`** on FlashList (prop does not exist in this codebase)
- Uncommitted `Podfile.lock` from local setup is local-only unless intentionally committed

## Optional ~/.zshrc

```bash
export PATH="/opt/homebrew/opt/ruby@3.3/bin:/opt/homebrew/lib/ruby/gems/3.3.0/bin:$PATH"
# in repo: nvm use 22.18.0
```
