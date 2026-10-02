---
name: iw2-commit
description: >-
  Commits the current working-tree changes as logically grouped Conventional
  Commits following safe Git practices. Inspects the diff, groups changes by
  concern, stages explicit paths, and writes clear commit messages. Does not
  push or open a pull request. Use when the user runs /commit, /iw2-commit, or
  asks to commit, save, or check in changes.
---

# Commit Changes

Turns the current working-tree changes into clean, logically grouped Conventional Commits — without pushing or opening a pull request.

## Usage

```text
/iw2-commit [optional context or scope]
# or
/commit [optional context or scope]
```

- `optional context or scope` — extra information about the change (e.g. a ticket, the intent, or which files to include)

---

## Workflow

### Step 1 — Inspect the repository

Run these before changing anything:

```bash
git status
git diff
git diff --staged
git log -n 10 --oneline
```

- Understand every changed, staged, renamed, and untracked file.
- Use the recent log to match the project's existing commit style (scopes, casing, language).
- If there are no changes, tell the user and stop.

---

### Step 2 — Check the current branch

- If the current branch is `main`, `master`, `develop`, `sandbox`, or another protected/base branch, **warn the user** and ask whether to:
  - create a new branch using **Conventional Branch** naming (`<type>/<short-description>`, e.g. `feature/add-order-import`, `fix/sidebar-color`, `docs/update-readme`), or
  - commit directly on the current branch.
- Keep branch names lowercase, hyphen-separated, and descriptive of the change.

---

### Step 3 — Respect pre-staged work

- If the user has already staged files, treat the staged set as intentional: commit **exactly** those files as a single commit.
- Do not add other files to that commit. Ask before committing the remaining unstaged changes.

---

### Step 4 — Group changes by concern

Split the changes into logical commits, one concern per commit. Typical splits:

- New feature code vs. its documentation
- Bug fix vs. unrelated refactor
- File renames/moves vs. content edits
- Dependency or tooling updates vs. application code

When there are **two or more groups**, or any file's purpose is unclear, present the proposed plan before committing:

```text
Proposed commits:

1. refactor: rename skills with iw2- prefix
   - skills/about-me/ -> skills/iw2-about-me/
   - skills/create-pr/ -> skills/iw2-create-pr/

2. docs(readme): document iw2- naming convention
   - README.md
```

Proceed once the user confirms (or adjusts) the grouping.

---

### Step 5 — Stage each group explicitly

- Stage with explicit paths: `git add <path> [<path>...]`.
- For files that mix concerns, stage hunks with `git add -p <path>`.
- **Never** use `git add -A` or `git add .` blindly.
- Before committing, confirm the staged set with `git diff --staged --stat`.

---

### Step 6 — Write the commit message

Use [Conventional Commits](https://www.conventionalcommits.org):

```text
<type>(<optional scope>)<!>: <subject>

<optional body — why the change was made>

<optional footer — BREAKING CHANGE:, Refs:, Co-authored-by:>
```

| Type | Use for |
|---|---|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no logic change |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `perf` | Performance improvement |
| `test` | Adding or updating tests |
| `build` | Build system or dependencies |
| `ci` | CI configuration |
| `chore` | Maintenance tasks |
| `revert` | Reverting a previous commit |

#### Message guidelines

- Subject in the imperative mood ("add", not "added"), ≤ 72 characters, no trailing period.
- Body explains **why**, not just what — include it when the change is non-trivial.
- Mark breaking changes with `!` after the type/scope and a `BREAKING CHANGE:` footer.
- Avoid generic subjects: `update`, `changes`, `fix stuff`, `wip`.
- Pass multi-line messages via a HEREDOC:

  ```bash
  git commit -m "$(cat <<'EOF'
  feat(orders): add bulk service-order import

  Operators needed to import hundreds of orders at once instead of
  creating them one by one.
  EOF
  )"
  ```

---

### Step 7 — Handle hooks

- Let pre-commit hooks run normally.
- If a hook fails, fix the reported issue, re-stage, and create a **new** commit.
- **Never** use `--no-verify` or `--amend` unless the user explicitly asks.

---

### Step 8 — Verify

```bash
git status
git log --oneline -n <number of commits created>
```

Confirm every intended change was committed and nothing unrelated slipped in.

---

### Step 9 — Final response

Provide a concise summary:

```text
Commits created on branch docs/update-readme:

- a1b2c3d refactor: rename skills with iw2- prefix
- d4e5f6a docs(readme): document iw2- naming convention

Left uncommitted:
- .env.local (contains secrets)

Next step: run /iw2-create-pr to push and open a pull request.
```

---

## Safety and Git Rules

- **Never** push — committing is local only. Use `/iw2-create-pr` to push and open a PR.
- **Never** amend, rebase, reset, or rewrite history unless explicitly requested.
- **Never** discard or overwrite user changes.
- **Never** commit secrets (`.env`, private keys, credentials, tokens) — warn the user instead.
- **Never** commit unrelated changes or large generated/binary files without confirming.
- If there are merge conflicts, unexpected changes, or ambiguity about which changes belong together — **stop and ask for clarification**.
