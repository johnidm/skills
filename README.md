<div align="center">

# skills

**This is my personal [Agent Skills](https://agentskills.io) for AI tools.**

Built and maintained by [Johni Douglas Marangon](https://github.com/johnidm) · Brazil

<br />

[![GitHub stars](https://img.shields.io/github/stars/johnidm/skills?style=for-the-badge&logo=github&logoColor=white)](https://github.com/johnidm/skills/stargazers)
[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-compatible-6366f1?style=for-the-badge)](https://agentskills.io)
[![skills.sh](https://img.shields.io/badge/skills.sh-installable-0ea5e9?style=for-the-badge)](https://skills.sh)

<br />

[Quick Start](#quick-start) · [Skills](#skills) · [Create a Skill](#creating-a-skill)

</div>

---

## Overview

A collection of agent skills I use in my daily work as a developer.

## Quick Start

**Install all skills**

```bash
npx skills add johnidm/skills
```

**Install one skill**

```bash
npx skills add johnidm/skills --skill about-me
```

**List available skills without installing**

```bash
npx skills add johnidm/skills --list
```

**Update after upstream changes**

```bash
npx skills update
```

## Skills

### `about-me`

Provides personal context about Johni Douglas Marangon (`johnidm`) by fetching live GitHub profile data.

Included as a sample skill to demonstrate how skills in this repo are structured, installed, and used.

```bash
npx skills add johnidm/skills --skill about-me
```

## Repository Structure

```
skills/
  <skill-name>/
    SKILL.md          # required — entry point the agent reads
    references/       # optional — longer supporting docs
    scripts/          # optional — scripts the skill can call
```

## Creating a Skill

1. Create `skills/<name>/SKILL.md`.
2. Fill in the YAML front-matter (`name`, `description`) — the `description` must make it clear **when** the agent should use the skill.
3. Write instructions as concrete steps, not vague advice.
4. Test locally:

```bash
npx skills add . --list
npx skills add . --skill <name>
```

## Links

| Resource | URL |
|---|---|
| Agent Skills spec | [agentskills.io](https://agentskills.io) |
| Skills CLI | [skills.sh](https://skills.sh) |
| Author — GitHub | [github.com/johnidm](https://github.com/johnidm) |
| Author — Medium | [medium.com/@johnidouglasmarangon](https://medium.com/@johnidouglasmarangon) |

---

<div align="center">

Made with care by [johnidm](https://github.com/johnidm)

</div>
