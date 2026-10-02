---
name: iw2-create-pr
description: >-
  Creates a GitHub pull request following safe Git practices. Handles branch
  creation with semantic naming, working-tree inspection, diff validation,
  pushing, and PR body generation. Use when the user runs /create-pr, /iw2-create-pr, or asks
  to open, submit, or publish a pull request.
---

# Create Pull Request

Automates the full pull request workflow — from branch naming to PR body generation — with built-in safety guardrails.

## Usage

```text
/iw2-create-pr [base branch] [optional additional information]
# or
/create-pr [base branch] [optional additional information]
```

- `base branch` — optional; if omitted the skill auto-detects it
- `optional additional information` — any extra context to include in the PR description

## Prerequisites

Before starting, run the integration detection script:

```bash
bash skills/iw2-create-pr/scripts/detect-github-integration.sh
```

This reports whether **GitHub CLI (`gh`)** or **GitHub MCP** is available.

- Prefer the available integration to create and manage the pull request.
- If **neither** `gh` nor GitHub MCP is available, inform the user before proceeding with any GitHub-specific operations.

---

## Workflow

### Step 1 — Determine the base branch

- If the user provides a base branch, use it.
- If no base branch is provided, run the suggestion script:

  ```bash
  bash skills/iw2-create-pr/scripts/suggest-base-branch.sh
  ```

- Verify that the selected base branch exists on the remote before continuing.
- Do **not** assume the base branch without checking the repository.

---

### Step 2 — Create a semantic branch

- If the current branch is `main`, `master`, `sandbox`, `develop`, or any other protected/base branch, create a new branch before making or committing changes.
- Use **Conventional Branch** naming: `<type>/<short-description>`
- Keep branch names lowercase, hyphen-separated, and concise.

#### Branch types and examples

| Type | Example |
|---|---|
| `feature/` | `feature/add-service-order-import` |
| `fix/` | `fix/sidebar-color` |
| `bugfix/` | `bugfix/resolve-authentication-error` |
| `hotfix/` | `hotfix/fix-production-login` |
| `refactor/` | `refactor/extract-audit-service` |
| `chore/` | `chore/update-dependencies` |
| `docs/` | `docs/add-api-documentation` |
| `test/` | `test/add-service-order-tests` |
| `perf/` | `perf/optimize-database-query` |
| `build/` | `build/update-node-version` |
| `ci/` | `ci/add-deployment-workflow` |
| `style/` | `style/improve-sidebar-layout` |
| `revert/` | `revert/revert-service-order-import` |

#### Branch naming guidelines

- Lowercase letters and hyphens only.
- Start with a semantic type prefix.
- Describe the *change*, not the implementation details.
- Avoid generic names: `my-branch`, `test`, `changes`, `new-feature`, `update`, `fix-stuff`.
- Omit ticket IDs unless the project conventions require them.

---

### Step 3 — Check the working tree

- Inspect current Git status before making any changes.
- Review existing changes to understand what belongs to the current task.
- If task-related changes are uncommitted, commit them with a meaningful semantic commit message.
- Follow the `iw2-commit` skill conventions when committing (logical grouping, Conventional Commits).
- **Do not** commit unrelated changes. Preserve them as unstaged or stashed.

---

### Step 4 — Validate the changes

Before creating the pull request:

- Review the diff between the development branch and the base branch.
- Run any relevant tests, linters, type checks, or other validation commands when applicable.
- Verify the development branch contains only the intended changes.
- Confirm the branch is based on the correct base branch.
- Resolve any issues that would prevent safe PR creation.

---

### Step 5 — Push the development branch

- Push the development branch to GitHub.
- **Never** force-push unless explicitly requested by the user.
- Verify the remote branch was created successfully.

---

### Step 6 — Create the pull request

Create the PR using the determined base branch. The PR must include:

**Title**
- Clear and concise.
- Describes the primary purpose of the change.

**Summary**
- Brief explanation of what was changed and why.

**Detailed description**
- Explains the implementation and relevant technical decisions.
- Includes examples when they help clarify the changes.

**Testing**
- Clear steps for testing or validating the changes when applicable.
- Mentions relevant automated tests that were executed.

**Study recommendations** *(optional)*
- Recommend documentation, concepts, or technical resources useful for understanding the implementation.
- Only include when they provide meaningful value.

---

### Step 7 — Final response

After the pull request is created, provide a concise summary:

```text
Pull request created successfully.

Branch: feature/add-service-order-import
Base: main

Changes:
- Added bulk service-order import.
- Added validation and confirmation steps.
- Added audit logging.

Tests:
- Unit tests passed.
- Type checking passed.

PR:
https://github.com/organization/repository/pull/123
```

---

## Safety and Git Rules

- **Never** force-push unless explicitly requested.
- **Never** reset, discard, or overwrite user changes without explicit permission.
- **Never** commit unrelated changes.
- **Never** merge the pull request unless explicitly requested.
- **Never** delete branches unless explicitly requested.
- Before creating the PR, verify the development branch contains the intended changes.
- Verify the base branch is correct.
- If there are merge conflicts, unexpected changes, authentication problems, or ambiguity about which changes belong to the task — **stop and ask for clarification** rather than making destructive assumptions.
- Preserve the user's existing work whenever possible.
