#!/usr/bin/env bash
# Fetches public GitHub profile data for the configured username.
# Usage: ./scripts/fetch-github-profile.sh [username]

set -euo pipefail

USERNAME="${1:-johnidm}"
BASE="https://api.github.com/users/${USERNAME}"

fetch() {
  curl -sf -H "Accept: application/vnd.github+json" "$1"
}

profile="$(fetch "${BASE}")"
repos="$(fetch "${BASE}/repos?sort=pushed&per_page=10")"
orgs="$(fetch "${BASE}/orgs")"

python3 - <<'PY' "$profile" "$repos" "$orgs"
import json, sys

profile = json.loads(sys.argv[1])
repos = json.loads(sys.argv[2])
orgs = json.loads(sys.argv[3])

print("# GitHub Profile\n")
print(f"**Username:** [{profile['login']}]({profile['html_url']})")
if profile.get("name"):
    print(f"**Name:** {profile['name']}")
if profile.get("bio"):
    print(f"**Bio:** {profile['bio']}")
if profile.get("location"):
    print(f"**Location:** {profile['location']}")
if profile.get("blog"):
    print(f"**Website:** {profile['blog']}")
if profile.get("email"):
    print(f"**Email:** {profile['email']}")
if profile.get("company"):
    print(f"**Company:** {profile['company']}")
if profile.get("hireable") is not None:
    print(f"**Open to work:** {'Yes' if profile['hireable'] else 'No'}")

print(f"\n**Member since:** {profile['created_at'][:10]}")
print(f"**Public repos:** {profile['public_repos']}")
print(f"**Followers:** {profile['followers']} | **Following:** {profile['following']}")

if orgs:
    print("\n## Organizations\n")
    for org in orgs:
        url = org.get("html_url") or f"https://github.com/{org['login']}"
        print(f"- [{org['login']}]({url})")

if repos:
    print("\n## Recent Repositories\n")
    for repo in repos:
        desc = repo.get("description") or "No description"
        lang = repo.get("language") or "N/A"
        stars = repo.get("stargazers_count", 0)
        print(f"- **[{repo['name']}]({repo['html_url']})** — {desc}")
        print(f"  Language: {lang} | Stars: {stars}")
PY
