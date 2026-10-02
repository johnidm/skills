#!/usr/bin/env bash
# collect-diff.sh
# Resolves the review target and prints its type, base ref, file stats, and diff.
#
# Usage:
#   collect-diff.sh              # uncommitted changes, or current branch vs base
#   collect-diff.sh staged       # staged changes only
#   collect-diff.sh <branch>     # branch vs base
#   collect-diff.sh #123 | <url> # GitHub PR (reported only; fetch with gh or MCP)
#   collect-diff.sh <path>...    # files/directories (reported only; read directly)

set -euo pipefail

REMOTE="origin"
CANDIDATES=(main master develop sandbox)

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "ERROR: Not inside a Git repository." >&2
  exit 1
fi

# ── Helpers ───────────────────────────────────────────────────────────────────
detect_base() {
  local ref
  for candidate in "${CANDIDATES[@]}"; do
    for ref in "$REMOTE/$candidate" "$candidate"; do
      if git rev-parse --verify --quiet "$ref" &>/dev/null; then
        echo "$ref"
        return 0
      fi
    done
  done
  ref=$(git symbolic-ref --quiet --short "refs/remotes/$REMOTE/HEAD" 2>/dev/null || true)
  if [[ -n "$ref" ]]; then
    echo "$ref"
    return 0
  fi
  return 1
}

print_section() {
  echo ""
  echo "=== $1 ==="
}

report_range() {
  local type="$1" head="$2" base merge_base
  if ! base=$(detect_base); then
    echo "ERROR: Could not detect a base branch. Pass one explicitly." >&2
    exit 1
  fi
  merge_base=$(git merge-base "$base" "$head")

  echo "Target: $type"
  echo "Head: $head"
  echo "Base: $base (merge-base ${merge_base:0:12})"

  if [[ -z "$(git rev-list "$merge_base..$head")" ]]; then
    echo ""
    echo "No commits on '$head' ahead of '$base'. Nothing to review."
    exit 0
  fi

  print_section "Commits"
  git log --oneline "$merge_base..$head"
  print_section "Changed files"
  git diff --stat "$merge_base" "$head"
  print_section "Diff"
  git diff "$merge_base" "$head"
}

# ── Resolve target ────────────────────────────────────────────────────────────
TARGET="${1:-}"

# GitHub pull request
if [[ "$TARGET" =~ ^#?[0-9]+$ || "$TARGET" =~ github\.com/.+/pull/[0-9]+ ]]; then
  echo "Target: pull request"
  echo "PR: ${TARGET#\#}"
  echo ""
  echo "Fetch it with GitHub CLI:  gh pr view ${TARGET#\#} && gh pr diff ${TARGET#\#}"
  echo "or with GitHub MCP if gh is unavailable."
  exit 0
fi

# Staged changes only
if [[ "$TARGET" == "staged" ]]; then
  if git diff --cached --quiet; then
    echo "Target: staged changes"
    echo ""
    echo "No staged changes. Nothing to review."
    exit 0
  fi
  echo "Target: staged changes"
  print_section "Changed files"
  git diff --cached --stat
  print_section "Diff"
  git diff --cached
  exit 0
fi

# Explicit branch
if [[ -n "$TARGET" ]] && git rev-parse --verify --quiet "$TARGET^{commit}" &>/dev/null; then
  report_range "branch" "$TARGET"
  exit 0
fi

# Files or directories
if [[ -n "$TARGET" ]]; then
  missing=()
  for path in "$@"; do
    [[ -e "$path" ]] || missing+=("$path")
  done
  if (( ${#missing[@]} > 0 )); then
    echo "ERROR: Not a branch, PR, or existing path: ${missing[*]}" >&2
    exit 1
  fi
  echo "Target: paths"
  print_section "Files"
  for path in "$@"; do
    if [[ -d "$path" ]]; then
      git ls-files -- "$path"
    else
      echo "$path"
    fi
  done
  echo ""
  echo "Read these files directly and review them as a whole."
  exit 0
fi

# Default: uncommitted changes, else current branch vs base
UNTRACKED=$(git ls-files --others --exclude-standard)
if ! git diff HEAD --quiet 2>/dev/null || [[ -n "$UNTRACKED" ]]; then
  echo "Target: uncommitted changes (staged + unstaged)"
  echo "Branch: $(git branch --show-current)"
  print_section "Changed files"
  git diff HEAD --stat
  if [[ -n "$UNTRACKED" ]]; then
    print_section "Untracked files (read these directly)"
    echo "$UNTRACKED"
  fi
  print_section "Diff"
  git diff HEAD
  exit 0
fi

report_range "current branch" "HEAD"
