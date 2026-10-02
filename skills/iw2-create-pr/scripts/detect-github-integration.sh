#!/usr/bin/env bash
# detect-github-integration.sh
# Detects whether GitHub CLI (gh) or GitHub MCP is available.
# Outputs a human-readable status report to stdout.

set -euo pipefail

GH_AVAILABLE=false
GH_AUTHENTICATED=false
MCP_AVAILABLE=false

# ── GitHub CLI detection ──────────────────────────────────────────────────────
if command -v gh &>/dev/null; then
  GH_AVAILABLE=true
  if gh auth status &>/dev/null; then
    GH_AUTHENTICATED=true
  fi
fi

# ── GitHub MCP detection ──────────────────────────────────────────────────────
# The MCP server typically sets GITHUB_MCP_SERVER or exposes a known env var.
# Also check for the Antigravity MCP config entry as a fallback.
if [[ -n "${GITHUB_MCP_SERVER:-}" ]] || \
   [[ -n "${GH_MCP_AVAILABLE:-}" ]] || \
   (command -v node &>/dev/null && node -e "
     const fs = require('fs');
     const paths = [
       process.env.HOME + '/.gemini/antigravity-ide/mcp',
       '.agents/mcp'
     ];
     const found = paths.some(p => {
       try { return fs.readdirSync(p).some(f => /github/i.test(f)); }
       catch { return false; }
     });
     process.exit(found ? 0 : 1);
   " &>/dev/null); then
  MCP_AVAILABLE=true
fi

# ── Report ────────────────────────────────────────────────────────────────────
echo "=== GitHub Integration Detection ==="
echo ""

if $GH_AVAILABLE; then
  if $GH_AUTHENTICATED; then
    echo "✅ GitHub CLI (gh): available and authenticated"
  else
    echo "⚠️  GitHub CLI (gh): installed but NOT authenticated (run: gh auth login)"
  fi
else
  echo "❌ GitHub CLI (gh): not installed"
fi

echo ""

if $MCP_AVAILABLE; then
  echo "✅ GitHub MCP: available"
else
  echo "❌ GitHub MCP: not detected"
fi

echo ""

# ── Recommendation ────────────────────────────────────────────────────────────
if $GH_AUTHENTICATED; then
  echo "Recommendation: use GitHub CLI (gh) to create the pull request."
elif $MCP_AVAILABLE; then
  echo "Recommendation: use GitHub MCP to create the pull request."
else
  echo "⚠️  WARNING: Neither GitHub CLI nor GitHub MCP is available."
  echo "   Inform the user before attempting GitHub-specific operations."
fi
