---
name: iw2-review-code
description: >-
  Reviews code changes for correctness bugs, security issues, and
  maintainability problems, then reports verified findings ranked by severity.
  Works on uncommitted changes, staged changes, a branch compared to its base,
  a GitHub pull request, or specific files. Read-only by default — it does not
  edit code unless asked. Use when the user runs /review-code, /iw2-review-code,
  /code-review, or asks to review, audit, or check a diff, branch, PR, or file.
---

# Review Code

Reviews a set of changes the way a careful senior engineer would: it understands the intent, reads the surrounding code, verifies each suspected problem, and reports only findings that hold up.

## Usage

```text
/iw2-review-code [target] [--fix] [optional focus]
# or
/review-code [target] [--fix] [optional focus]
```

- `target` — optional. One of:
  - *(empty)* — uncommitted changes (staged + unstaged); if there are none, the current branch compared to its base
  - `staged` — only staged changes
  - `<branch>` — that branch compared to its base
  - `#123` or a PR URL — a GitHub pull request
  - `<path>...` — specific files or directories, reviewed as a whole (not as a diff)
- `--fix` — after reporting, apply the fixes the user approves
- `optional focus` — narrows the review (e.g. `security`, `performance`, `the auth changes`)

---

## Workflow

### Step 1 — Resolve the review target

Run the target-resolution script from this skill directory:

```bash
bash scripts/collect-diff.sh [target]
```

It prints the target type, the base ref (when there is one), the changed-file stats, and the full diff.

- For a PR target, use GitHub CLI (`gh pr view`, `gh pr diff`) or GitHub MCP. If neither is available, tell the user and stop.
- For a path target, read the files directly — there is no diff.
- If the target is empty (no changes, no commits ahead of base), tell the user and stop.
- If the diff is very large (over ~2,000 changed lines), tell the user, then review the highest-risk files first (see Step 3) and say which files were not reviewed in depth.

---

### Step 2 — Understand the intent

Before judging the code, work out what it is trying to do:

- Read the commit messages (`git log <base>..HEAD`) or the PR title, body, and linked issue.
- Read project guidance if present: `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, lint and formatter configs.
- Note the language, frameworks, and conventions already used in the touched files.

A change cannot be judged correct or incorrect without knowing what it is supposed to do. If the intent is unclear and it matters, say so in the report.

---

### Step 3 — Review the changes

Review every changed hunk **with its surrounding context** — open the full file, and follow callers and callees of changed functions when behavior changes.

Prioritize files in this order:

1. Security-sensitive code (auth, permissions, input parsing, queries, secrets, crypto)
2. Data writes, migrations, and anything hard to reverse
3. Core business logic and public APIs
4. Concurrency, error handling, and resource management
5. Tests, configuration, and docs

Use [references/checklist.md](references/checklist.md) as the review checklist. Cover these categories, in this order of importance:

| Category | What to look for |
|---|---|
| **Correctness** | Logic errors, wrong conditions, off-by-one, null/undefined handling, broken edge cases, behavior that contradicts the stated intent |
| **Security** | Injection, missing authorization, unsafe deserialization, secrets in code, unvalidated input, SSRF, path traversal |
| **Reliability** | Unhandled errors, swallowed exceptions, race conditions, resource leaks, missing timeouts, non-idempotent retries |
| **Data** | Unsafe migrations, missing transactions, data loss, breaking schema or API contract changes |
| **Performance** | N+1 queries, work inside hot loops, unbounded memory or result sets, missing indexes for new queries |
| **Tests** | New behavior without tests, tests that do not assert the change, deleted or weakened tests |
| **Maintainability** | Duplicated logic that already exists in the codebase, dead code, misleading names, needless complexity |

Do **not** report:

- Pure style issues a formatter or linter would catch.
- Preferences that do not match the project's existing conventions.
- Problems in unchanged code, unless the change makes them reachable or worse.

---

### Step 4 — Verify every finding

For each suspected issue, try to **disprove** it before reporting:

- Re-read the code path end to end. Check whether a caller, guard, type, framework default, or test already handles the case.
- Build a concrete failure scenario: specific input or state → specific wrong result, crash, or exposure.
- When cheap and safe, confirm it: run the relevant test, a type check, or a small read-only script. Never run commands that modify data, call external services, or push anything.

Then label each surviving finding:

- **Confirmed** — the failure scenario was traced or reproduced.
- **Likely** — strong evidence, but depends on something not verifiable here (runtime config, external service).

Drop anything you cannot back with a concrete scenario.

---

### Step 5 — Assign severity

| Severity | Meaning |
|---|---|
| 🔴 **Critical** | Security hole, data loss or corruption, or a crash on a common path. Must fix before merge. |
| 🟠 **High** | Incorrect behavior users will hit, or a broken contract. Should fix before merge. |
| 🟡 **Medium** | Edge-case bug, missing error handling, missing test for risky logic, notable performance cost. |
| 🔵 **Low** | Maintainability or clarity improvement with a concrete benefit. |

---

### Step 6 — Report

Use this format. Rank findings most severe first. Keep each finding short and specific.

````markdown
## Code Review — <target> (base: <base ref>)

**Summary:** <one or two sentences: what the change does and overall assessment>
**Verdict:** ✅ Ready to merge | ⚠️ Merge after fixes | ❌ Needs rework

### Findings

#### 1. 🔴 Critical — SQL injection in order search · Confirmed
`src/orders/search.ts:42`

**Problem:** `term` is interpolated directly into the SQL string.
**Scenario:** searching for `' OR 1=1 --` returns every customer's orders.
**Fix:** use a parameterized query:
```ts
db.query("SELECT * FROM orders WHERE name ILIKE $1", [`%${term}%`]);
```

#### 2. 🟡 Medium — ...

### Not reviewed in depth
- <files skipped or skimmed, and why — omit this section if none>

### Checks run
- <tests, type checks, or scripts executed and their result — omit if none>
````

- Reference code as `path:line` so it is clickable.
- If there are no findings, say so plainly and state what was reviewed. Do not invent findings to fill the report.
- Mention notably good decisions only in one line within the summary, and only if they are worth repeating.

---

### Step 7 — Apply fixes (only with `--fix` or when asked)

- Ask which findings to fix, unless the user said to fix all of them.
- Apply the narrowest change that resolves each finding, matching the surrounding code style.
- Run the relevant tests, linters, or type checks after editing and report the results.
- Do **not** commit. Suggest the `iw2-commit` skill if the user wants to commit the fixes.

---

## Rules

- **Read-only by default.** Never edit, commit, push, or comment on a PR unless the user asks.
- **Never** post review comments to GitHub without explicit permission.
- **Never** run commands with side effects (migrations, deploys, writes to external services) to verify a finding.
- Prefer fewer, verified findings over many speculative ones.
- Be direct about problems and neutral in tone — review the code, not the author.
- If the target, base branch, or intent is ambiguous in a way that changes the review, **ask** before starting.
