<div align="center">

# skills

**This is my personal [Agent Skills](https://agentskills.io) for AI tools.**

Built and maintained by [Johni Douglas Marangon](https://github.com/johnidm) · Brazil

<br />

[![GitHub stars](https://img.shields.io/github/stars/johnidm/skills?style=for-the-badge&logo=github&logoColor=white)](https://github.com/johnidm/skills/stargazers)
[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-compatible-6366f1?style=for-the-badge)](https://agentskills.io)
[![skills.sh](https://img.shields.io/badge/skills.sh-installable-0ea5e9?style=for-the-badge)](https://skills.sh)

<br />

[Quick Start](#quick-start) · [Skills](#available-skills) · [Create a Skill](#creating-a-skill)

</div>

---

## Overview

A collection of agent skills I use in my daily work as a developer.

### Naming Convention (`iw2-`)

All skills in this repository use the `iw2` prefix, which stands for **"I want to"**:

* `iw2-create-pr` (*"I want to create a PR"*)
* `iw2-review-code` (*"I want to review code"*)
* `iw2-run-tests` (*"I want to run tests"*)

This prefix is applied consistently across all skills to clearly express the user's intent when invoking or installing agent workflows.

## Quick Start

**Install all skills**

```bash
npx skills add johnidm/skills
```

**Install one skill**

```bash
npx skills add johnidm/skills --skill iw2-about-me
```

**List available skills without installing**

```bash
npx skills add johnidm/skills --list
```

**Update after upstream changes**

```bash
npx skills update
```

## Available Skills

### `iw2-about-me`

Provides personal context about Johni Douglas Marangon (`johnidm`) by fetching live GitHub profile data.

Included as a sample skill to demonstrate how skills in this repo are structured, installed, and used.

```bash
npx skills add johnidm/skills --skill iw2-about-me
```

### `iw2-commit`

Commits the current working-tree changes as logically grouped Conventional Commits. Inspects the diff, groups changes by concern, stages explicit paths, and writes clear commit messages — without pushing or opening a PR.

**Use when:** the user runs `/commit`, `/iw2-commit`, or asks to commit, save, or check in changes.

```bash
npx skills add johnidm/skills --skill iw2-commit
```

### `iw2-create-pr`

Creates a GitHub pull request following safe Git practices. Handles branch creation with semantic naming, working-tree inspection, diff validation, pushing, and PR body generation.

**Use when:** the user runs `/create-pr`, `/iw2-create-pr`, or asks to open, submit, or publish a pull request.

```bash
npx skills add johnidm/skills --skill iw2-create-pr
```

### `iw2-grill-me`

Interviews you with sharp, one-at-a-time questions about a plan, idea, design, or request, using the context you provide (text, files, a doc, or the codebase). Surfaces gaps, hidden assumptions, risks, and undecided choices, recommends an answer for each question, and ends with a summary of decisions and open questions. Read-only.

**Use when:** the user runs `/grill-me`, `/iw2-grill-me`, or asks to be grilled, challenged, interviewed, or stress-tested on a plan or idea.

```bash
npx skills add johnidm/skills --skill iw2-grill-me
```

### `iw2-review-code`

Reviews code changes for correctness bugs, security issues, and maintainability problems. Reads the surrounding code, verifies each suspected issue with a concrete failure scenario, and reports findings ranked by severity with a merge verdict. Works on uncommitted changes, staged changes, a branch, a GitHub PR, or specific files. Read-only by default; pass `--fix` to apply approved fixes.

**Use when:** the user runs `/review-code`, `/iw2-review-code`, `/code-review`, or asks to review, audit, or check a diff, branch, PR, or file.

```bash
npx skills add johnidm/skills --skill iw2-review-code
```

### `iw2-tour-code`

Explains how a repository or feature works by tracing a real request, command, or event through the code, stop by stop, with file and line references. Produces a flow map, the data and side effects at each stop, where to change things, and non-obvious gotchas. Read-only.

**Use when:** the user runs `/tour-code`, `/iw2-tour-code`, `/code-tour`, or wants a codebase walkthrough, onboarding, or to know where or how behavior is implemented. Not for code reviews or README rewrites.

```bash
npx skills add johnidm/skills --skill iw2-tour-code
```

## Repository Structure

```
skills/
  iw2-<skill-name>/
    SKILL.md          # required — entry point the agent reads
    references/       # optional — longer supporting docs
    scripts/          # optional — scripts the skill can call
```

## Creating a Skill

All skills follow the `iw2-` prefix convention (**"I want to"**):

1. Create `skills/iw2-<name>/SKILL.md`.
2. Fill in the YAML front-matter (`name: iw2-<name>`, `description`) — the `description` must make it clear **when** the agent should use the skill.
3. Write instructions as concrete steps, not vague advice.
4. Test locally:

```bash
npx skills add . --list
npx skills add . --skill iw2-<name>
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
