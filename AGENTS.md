# flash-list

High-performance React Native list (FlatList replacement) built on recycling. Used widely for smooth scrolling on large datasets.

## Layout

- `src/` — library (TypeScript)
- `fixture/react-native/` — test/demo app
- `dist/` — build output (not rebuilt on branch switch)

## Constraint

`estimatedItemSize` is not a FlashList prop. Do not use, suggest, or add it.

## Build & test

```bash
yarn build          # compile to dist/
yarn test --forceExit
yarn type-check
yarn lint
```

Run `yarn build` after checking out another branch. Node **22.18.0**.

## Commits & PRs

- Conventional commits: `fix(scope): …`, `feat(scope): …` (scopes: `layout`, `hooks`, `scroll`, `sticky-headers`, `recycling`, `viewability`)
- No AI attribution in commits or PRs
- PR titles under 70 chars; body includes `Fixes #<n>` when applicable

## Agent PR token (mandatory)

Agent PRs must use `SHOPIFY_GH_ACCESS_TOKEN` for creation (CI: `$AGENT_PR_TOKEN`):

```bash
GH_TOKEN="$AGENT_PR_TOKEN" gh pr create ...
```

Use `GITHUB_TOKEN` for everything else. Bare `gh pr create` yields unmergeable PRs.

## CI cleanup (mandatory)

Kill processes you started before finishing CI (especially Metro on 8081):

```bash
lsof -ti:8081 | xargs kill -9 2>/dev/null || true
```

## Skills

Read the matching `SKILL.md` when the task fits.

### `.claude/skills/` (workflows & CI)

| Skill | Use when |
|---|---|
| `fix-github-issue` | End-to-end bug fix: repro, diagnose, fix, simulator, PR |
| `raise-pr` | Open PR (conventions, no AI attribution) |
| `review-and-test` | Review branch/PR: tests, lint, device, RTL/LTR |
| `triage-issue` | Classify issue (P0/P1/P2), duplicates, labels |
| `agent-device` | Simulator/emulator via snapshots (coordinates) |
| `upgrade-react-native` | Bump fixture React Native version |
| `analyze-feedback` | Mine CI agent feedback into skills / this file |

### `.cursor/skills/` (local dev & device)

| Skill | Use when |
|---|---|
| `init-ios` | First-time macOS iOS setup (`/init-ios`) |
| `init-android` | First-time macOS Android setup (`/init-android`) |
| `start-ios-simulator` | Start TS watch, Metro, fixture on simulator |
| `start-android-emulator` | Start TS watch, Metro, fixture on emulator |
| `ios-simulator` | Validate fixture UI on iOS after app is installed |
| `ios-simulator-validation-loop` | Observe–act–verify loop on iOS (snapshots, screenshots) |
| `android-emulator` | Validate fixture UI on Android after app is installed |

## Self-learning

Capture pitfalls, debugging wins, and non-obvious FlashList/RN behavior in the right place:

- Bugs → `fix-github-issue` (Common Pitfalls)
- Testing → `review-and-test` (Edge Cases)
- Devices → `agent-device` or `.cursor/skills/*-simulator*` / `android-emulator`
- Repo-wide → this file (`AGENTS.md`)
- CI feedback batches → `analyze-feedback`

Same PR as the fix; one line per pitfall. On CI, only critical repeat-failure learnings.
