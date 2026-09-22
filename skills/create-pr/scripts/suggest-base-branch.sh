#!/usr/bin/env bash
# suggest-base-branch.sh
# Suggests the most appropriate base branch for a pull request by inspecting
# the remote refs. Outputs the branch name to stdout.

set -euo pipefail

REMOTE="${1:-origin}"

# Priority-ordered list of common base branch names
CANDIDATES=(main master sandbox develop)

# ── Fetch remote branches ─────────────────────────────────────────────────────
if ! git remote get-url "$REMOTE" &>/dev/null; then
  echo "ERROR: Remote '$REMOTE' not found." >&2
  exit 1
fi

# Refresh remote refs quietly
git fetch "$REMOTE" --prune --quiet 2>/dev/null || true

REMOTE_BRANCHES=$(git branch -r --format="%(refname:short)" 2>/dev/null | sed "s|^${REMOTE}/||")

# ── Match against priority list ───────────────────────────────────────────────
for candidate in "${CANDIDATES[@]}"; do
  if echo "$REMOTE_BRANCHES" | grep -qx "$candidate"; then
    echo "$candidate"
    exit 0
  fi
done

# ── Fallback: use remote HEAD ─────────────────────────────────────────────────
HEAD_BRANCH=$(git remote show "$REMOTE" 2>/dev/null \
  | awk '/HEAD branch/ {print $NF}')

if [[ -n "$HEAD_BRANCH" && "$HEAD_BRANCH" != "(unknown)" ]]; then
  echo "$HEAD_BRANCH"
  exit 0
fi

# ── Last resort: first remote branch alphabetically ──────────────────────────
FIRST=$(echo "$REMOTE_BRANCHES" | head -n 1)
if [[ -n "$FIRST" ]]; then
  echo "$FIRST"
  exit 0
fi

echo "ERROR: Could not determine a base branch from remote '$REMOTE'." >&2
exit 1
