---
name: iw2-update-deps
description: >-
  Updates project dependencies safely, then runs the project's quality checks
  and reports the outcome. Inspects available updates, upgrades while weighing
  compatibility and breaking changes, runs tests, linting, type checking,
  formatting, and other configured validators, fixes what the upgrade broke,
  and ends with a summary of versions, notable changes, new capabilities,
  breaking changes, check results, and follow-ups. Use when the user runs
  /update-deps, /iw2-update-deps, or asks to update, upgrade, or bump
  dependencies, packages, or libraries.
---

# Update Dependencies

Upgrades a project's dependencies the way a careful engineer would: find what can move, move it deliberately, prove the project still works with its own tooling, and fix what the upgrade broke before calling it done.

## Usage

```text
/iw2-update-deps [scope or package names] [--major]
# or
/update-deps [scope or package names] [--major]
```

- `scope or package names` — optional. Limit the update to specific packages (e.g. `react react-dom`) or a group (e.g. `dev dependencies`). Empty means all dependencies.
- `--major` — allow major-version (potentially breaking) upgrades. Without it, stay within compatible (minor/patch) ranges unless the user asks otherwise.

---

## Workflow

### Step 1 — Detect the ecosystem and tooling

Before touching anything, learn how this project manages dependencies and verifies itself.

- Identify the package manager and manifest from the lockfile and manifest present:
  - Node — `package.json` + `package-lock.json` / `yarn.lock` / `pnpm-lock.yaml` / `bun.lockb`
  - Python — `pyproject.toml` + `uv.lock` / `poetry.lock` / `requirements*.txt`, or `Pipfile.lock`
  - Rust — `Cargo.toml` + `Cargo.lock`
  - Go — `go.mod` + `go.sum`
  - Ruby — `Gemfile` + `Gemfile.lock`; PHP — `composer.json` + `composer.lock`
- Read project guidance that constrains upgrades: `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, CI config, engine/runtime version pins.
- Discover the quality-check commands the project actually uses (scripts in `package.json`, `Makefile`, `justfile`, `tox.ini`, `pyproject.toml`, pre-commit config, CI workflow). Record the exact commands for: **tests**, **lint**, **type check**, **format check**, and any other validators (security audit, build, migrations check).
- If the package manager or the check commands are ambiguous, ask before proceeding.

---

### Step 2 — Establish a clean baseline

- Run `git status`. If the working tree is dirty, warn the user — the upgrade diff must be separable from unrelated changes. Ask whether to proceed, stash, or stop.
- If the branch is `main`, `master`, `develop`, or another protected branch, suggest creating a branch (e.g. `build/update-dependencies`) before making changes.
- Run the full check suite **once, before any upgrade**, to confirm the project is green to begin with. If something is already failing, note it — those failures are not caused by the upgrade, and you must not claim to have introduced or fixed them.

---

### Step 3 — Inspect available updates

List what can be upgraded and how far, without changing anything yet. Use the ecosystem's own tooling, for example:

- Node — `npm outdated`, `yarn outdated`, or `pnpm outdated`
- Python — `uv lock --upgrade --dry-run`, `poetry show --outdated`, or `pip list --outdated`
- Rust — `cargo update --dry-run` (and `cargo outdated` if available)
- Go — `go list -u -m all`
- Ruby — `bundle outdated`; PHP — `composer outdated`

For each candidate, classify the jump as **patch**, **minor**, or **major** against the project's declared range. Separate security-driven updates (audit advisories) from routine ones. Present the list before upgrading, grouped by risk, so the user can confirm scope.

---

### Step 4 — Update dependencies deliberately

- Honor the scope and the `--major` flag from Usage. Without `--major`, keep to compatible ranges; call out held-back majors in the summary instead of forcing them.
- Prefer upgrading in sensible groups rather than all at once when majors are involved — e.g. a framework and its ecosystem packages together, so a failure points at a clear cause.
- Update both the manifest and the lockfile with the package manager's own commands (never hand-edit a lockfile). Keep version-range style consistent with what the project already uses.
- For any major upgrade, read that package's changelog / release notes / migration guide first and note the breaking changes you expect to hit.

---

### Step 5 — Run the project's quality checks

Run the commands discovered in Step 1, using the project's real scripts (not assumed defaults). Run each and capture its result:

- **Tests** — the project's test command.
- **Lint** — the configured linter.
- **Type check** — the configured type checker (e.g. `tsc --noEmit`, `mypy`, `pyright`).
- **Format check** — the formatter in check mode (e.g. `prettier --check`, `ruff format --check`, `gofmt -l`).
- **Other validators** — build, security audit, schema/migration checks, or anything else the project runs in CI.

If a category has no configured tooling, say so explicitly rather than skipping silently. Capture actual output for each — pass/fail and the key errors.

---

### Step 6 — Fix what the upgrade broke

- For each failure, determine whether the upgrade caused it (compare against the Step 2 baseline). Pre-existing failures are reported, not silently "fixed."
- Apply the migration the new version requires — renamed APIs, changed defaults, moved imports, adjusted config — guided by the changelog from Step 4. Make the narrowest change that resolves the breakage and matches surrounding code style.
- Re-run the affected checks after each fix. Repeat until the suite is green or you hit a blocker you cannot resolve safely.
- If a fix would require large or risky application changes, stop and surface it as a decision for the user rather than forcing it through.

---

### Step 7 — Report

Do **not** declare the update complete until every relevant check has been run and its result reported. Use this format:

````markdown
## Dependency Update — <scope>

**Summary:** <one or two sentences: what moved and overall assessment>

### Updated dependencies
| Package | From | To | Jump |
|---|---|---|---|
| react | 18.2.0 | 18.3.1 | minor |
| vitest | 1.6.0 | 2.1.1 | major |

### Notable changes & improvements
- <package>: <what the new versions bring — fixes, perf, deprecations>

### New capabilities worth adopting
- <new API/feature now available and where it could help — suggestion only, not applied unless asked>

### Breaking changes & compatibility
- <breaking change hit and how it was handled, or a held-back major and why>

### Checks run
| Check | Command | Result |
|---|---|---|
| Tests | `npm test` | ✅ 214 passed |
| Lint | `npm run lint` | ✅ clean |
| Type check | `tsc --noEmit` | ✅ no errors |
| Format | `prettier --check .` | ✅ clean |
| Audit | `npm audit` | ⚠️ 1 moderate (no fix available) |

### Remaining issues & follow-ups
- <anything unresolved, held back, or recommended next — or "none">
````

- If a check has no tooling in the project, list it as `— not configured`.
- Do not commit or push. Suggest the `iw2-commit` skill if the user wants to commit the upgrade.

---

## Rules

- **Never** declare success until tests, lint, type check, format check, and any other configured validators have actually been run and their real results reported.
- **Never** hand-edit a lockfile — use the package manager so manifest and lockfile stay consistent.
- **Never** downgrade or remove a dependency to make a check pass without telling the user.
- **Never** disable, skip, or weaken tests, linters, or type checks to turn the suite green — fix the cause or report it.
- **Never** push, and do not commit unless the user asks.
- Keep upgrade changes separate from unrelated edits so the diff is reviewable.
- Report pre-existing failures as pre-existing; report honestly when a check could not be run and why.
- If scope, compatibility, or a required migration is ambiguous in a way that affects the outcome, **stop and ask**.
