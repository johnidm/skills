# skills

A collection of personal agent skills I use in my daily work as a developer.

Useful links
- [Agent Skills](https://agentskills.io)
- [skills.sh](https://skills.sh).

## Installation

Install all skills:

```bash
npx skills add johnidm/skills
```

Install a specific skill:

```bash
npx skills add johnidm/skills --skill about-me
```

List the skills available in this repo without installing anything:

```bash
npx skills add johnidm/skills --list
```

Update after changes in the repo:

```bash
npx skills update
```

## Available skills

| Skill | Description |
|---|---|
| `about-me` | Fetches live GitHub profile data for personal context about Johni Douglas Marangon |

## Structure

```
skills/
  <skill-name>/
    SKILL.md          # required — entry point the agent reads
    references/        # optional — longer supporting docs
    scripts/            # optional — scripts the skill can call
```

## Creating a new skill

1. Create `skills/<name>/SKILL.md`.
2. Fill in the YAML front-matter (`name`, `description`) — the `description` must make it clear WHEN the agent should use the skill.
3. Write instructions as concrete steps, not vague advice.
4. Test locally: `npx skills add . --list` and `npx skills add . --skill <name>`.
