---
name: about-me
description: >-
  Provides personal context about Johni Douglas Marangon (johnidm) by fetching
  live GitHub profile data. Use when the user asks about me, my background,
  who I am, my GitHub, my repos, or when personal developer context would
  help tailor a response.
---

# About Me

Personal context skill for **Johni Douglas Marangon** (`johnidm`).

## When to use

- User asks "who are you?", "about me", "my background", or similar
- Task benefits from knowing the user's stack, interests, or public work
- Referencing recent repos, bio, or professional context from GitHub

## Workflow

1. Run the fetch script from this skill directory:

```bash
bash scripts/fetch-github-profile.sh
```

Override the username if needed:

```bash
bash scripts/fetch-github-profile.sh johnidm
```

2. Read the script output — it contains live public data from the GitHub API.
3. Use the profile to personalize your response. Do not invent details not present in the output.

## Quick reference (static)

These facts rarely change; prefer the script for repos and stats.

| Field | Value |
|---|---|
| Name | Johni Douglas Marangon |
| GitHub | https://github.com/johnidm |
| Location | Brazil |
| Blog | https://medium.com/@johnidouglasmarangon |
| Focus | Senior engineer, 18+ years building software from scratch |

## Response guidelines

- Lead with name, role, and one-line bio when introducing the user
- Mention top recent repos only when relevant to the task
- Keep tone professional and concise
- Link to GitHub or specific repos when citing public work
