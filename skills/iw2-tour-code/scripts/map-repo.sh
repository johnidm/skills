#!/usr/bin/env bash
# map-repo.sh
# Prints a quick orientation map of a repository: languages, manifests,
# framework hints, top-level layout, and likely entry points.
#
# Usage:
#   map-repo.sh [path]   # defaults to the current directory

set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"

# ── File list (respects .gitignore when inside a Git repo) ────────────────────
if git rev-parse --is-inside-work-tree &>/dev/null; then
  FILES=$(git ls-files --cached --others --exclude-standard)
else
  FILES=$(find . -type f \
    -not -path '*/node_modules/*' -not -path '*/.git/*' \
    -not -path '*/vendor/*' -not -path '*/dist/*' -not -path '*/build/*' \
    -not -path '*/.venv/*' -not -path '*/venv/*' | sed 's|^\./||')
fi

if [[ -z "$FILES" ]]; then
  echo "No files found in '$ROOT'."
  exit 0
fi

section() {
  echo ""
  echo "=== $1 ==="
}

echo "Repository: $(pwd)"
echo "Files: $(echo "$FILES" | wc -l | tr -d ' ')"

# ── Languages (by file extension) ─────────────────────────────────────────────
section "Languages (top extensions)"
echo "$FILES" | grep -E '\.[A-Za-z0-9]+$' | sed -E 's/.*\.([A-Za-z0-9]+)$/\1/' \
  | grep -vE '^(md|txt|json|lock|yml|yaml|toml|svg|png|jpg|jpeg|gif|ico|map|snap)$' \
  | sort | uniq -c | sort -rn | head -n 8 || true

# ── Top-level layout ──────────────────────────────────────────────────────────
section "Top-level layout (files per entry)"
echo "$FILES" | awk -F/ '{print (NF > 1 ? $1 "/" : $1)}' | sort | uniq -c | sort -rn | head -n 20

# ── Manifests and docs ────────────────────────────────────────────────────────
section "Manifests and docs"
echo "$FILES" | grep -E '(^|/)(package\.json|pyproject\.toml|requirements[^/]*\.txt|setup\.py|go\.mod|Cargo\.toml|Gemfile|pom\.xml|build\.gradle(\.kts)?|composer\.json|mix\.exs|.*\.csproj|Dockerfile|docker-compose[^/]*\.ya?ml|compose\.ya?ml|Procfile|Makefile|README[^/]*|CLAUDE\.md|AGENTS\.md|ARCHITECTURE[^/]*|CONTRIBUTING[^/]*)$' \
  | grep -v node_modules | head -n 30 || echo "(none found)"

# ── Framework hints ───────────────────────────────────────────────────────────
section "Framework hints"
HINTS=""
add_hint() { HINTS="${HINTS}$1"$'\n'; }

for f in $(echo "$FILES" | grep -E '(^|/)package\.json$' | grep -v node_modules | head -n 10); do
  for fw in next react vue nuxt svelte @angular/core express fastify koa @nestjs/core hono electron commander yargs; do
    grep -q "\"$fw\"" "$f" 2>/dev/null && add_hint "$fw ($f)"
  done
done

for f in $(echo "$FILES" | grep -E '(^|/)(pyproject\.toml|requirements[^/]*\.txt|setup\.py)$' | head -n 10); do
  for fw in django flask fastapi celery click typer sqlalchemy; do
    grep -qi "$fw" "$f" 2>/dev/null && add_hint "$fw ($f)"
  done
done

for f in $(echo "$FILES" | grep -E '(^|/)go\.mod$' | head -n 5); do
  for fw in gin-gonic/gin labstack/echo gofiber/fiber go-chi/chi spf13/cobra; do
    grep -q "$fw" "$f" 2>/dev/null && add_hint "$fw ($f)"
  done
done

for f in $(echo "$FILES" | grep -E '(^|/)Cargo\.toml$' | head -n 5); do
  for fw in axum actix-web rocket tokio clap; do
    grep -q "^$fw" "$f" 2>/dev/null && add_hint "$fw ($f)"
  done
done

echo "$FILES" | grep -qE '(^|/)Gemfile$' && grep -q "rails" Gemfile 2>/dev/null && add_hint "rails (Gemfile)"
echo "$FILES" | grep -qE '(^|/)manage\.py$' && add_hint "django (manage.py)"

# Fallback for repos without manifests: scan source imports
if [[ -z "$HINTS" ]]; then
  IMPORTS=$(echo "$FILES" | grep -E '\.(py|js|jsx|ts|tsx|mjs|go)$' \
    | grep -vE '(^|/)(node_modules|vendor|dist|build)/' | head -n 200 \
    | tr '\n' '\0' \
    | xargs -0 grep -hoE '^(from|import) (fastapi|flask|django|celery|click|typer)|require\(["'"'"'](express|fastify|koa)["'"'"']\)|from ["'"'"'](express|fastify|koa|hono|next|react|vue)["'"'"']|"github\.com/(gin-gonic/gin|labstack/echo|gofiber/fiber|go-chi/chi|spf13/cobra)' 2>/dev/null \
    | sed -E 's/^(from|import) //; s/^require\(.(.*).\)$/\1/; s/^from .(.*).$/\1/; s/^"github\.com\///' \
    | sort -u || true)
  for fw in $IMPORTS; do add_hint "$fw (imports)"; done
fi

if [[ -n "$HINTS" ]]; then
  printf '%s' "$HINTS" | sort -u
else
  echo "(none detected)"
fi

# ── Likely entry points ───────────────────────────────────────────────────────
section "Likely entry points"
echo "$FILES" | grep -E '(^|/)(main|index|app|server|cli|wsgi|asgi|manage|__main__|program|Program)\.[A-Za-z]+$|(^|/)(cmd|bin)/[^/]+|(^|/)(app|pages)/(api/)?.*(route|page)\.[jt]sx?$' \
  | grep -vE '(^|/)(node_modules|test|tests|__tests__|spec|examples?|fixtures)/' \
  | head -n 25 || true

# ── Routing and handler hints ─────────────────────────────────────────────────
section "Files that register routes, commands, or handlers (sample)"
HANDLERS=$(echo "$FILES" | grep -E '\.(js|jsx|ts|tsx|mjs|py|go|rb|rs|java|kt|cs|php|ex)$' \
  | grep -vE '(^|/)(node_modules|vendor|dist|build)/' | head -n 2000 \
  | tr '\n' '\0' \
  | xargs -0 grep -lE '(\.(get|post|put|patch|delete)\(["'"'"'`/]|@(app|router)\.(get|post|put|patch|delete|route)|@(Get|Post|Put|Patch|Delete|Controller)\(|HandleFunc\(|\.command\(|add_parser\(|@click\.command|cobra\.Command|\.subscribe\(|\.on\(["'"'"'][a-z_.:-]+["'"'"']|@shared_task|@celery)' 2>/dev/null \
  | head -n 20 || true)
echo "${HANDLERS:-(none found)}"
