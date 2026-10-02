---
name: iw2-grill-me
description: >-
  Interviews the user with sharp, one-at-a-time questions about a plan, idea,
  design, or request, using the context they provide (text, files, a doc, or
  the codebase) to find gaps, hidden assumptions, risks, and undecided choices
  before any work starts. Ends with a summary of decisions and open questions.
  Use when the user runs /grill-me or /iw2-grill-me, or asks to be grilled,
  challenged, interviewed, or stress-tested on a plan or idea. Do not use to
  implement the plan or to review finished code.
---

# Grill Me

Stress-tests a plan or request by asking the user pointed questions, one at a time, grounded in the context they provide. The goal is a shared, decided understanding — not a finished implementation.

## Usage

```text
/iw2-grill-me [context] [prompt]
# or
/grill-me [context] [prompt]
```

- `context` — what the questions are based on. Any of:
  - pasted text (a spec, an idea, a ticket, meeting notes)
  - file or folder paths (`docs/plan.md`, `src/billing/`)
  - a URL or document the agent can read
  - *(empty)* — use the current conversation and the repository
- `prompt` — what the user wants to do or decide, e.g. `I want to migrate auth to OAuth`, `grill me on this pricing page`, `is this design ready to build?`

If the prompt is missing, ask for it in one question before starting. If both are missing, ask what the user wants to be grilled on.

## When not to use

- **Implementing** the plan → finish the grilling, then hand off to a build task.
- **Reviewing finished code** → use `iw2-review-code`.
- **Explaining how existing code works** → use `iw2-tour-code`.

---

## Workflow

### Step 1 — Absorb the context

- Read everything the user pointed at: pasted text, files, folders, links.
- If the prompt touches the codebase, explore the relevant code so questions are grounded in what actually exists.
- **Do not ask what you can look up.** If a question can be answered by reading the code, docs, or config, answer it yourself and state the finding instead.
- Do not change any files during the session.

---

### Step 2 — Map what is undecided

Before the first question, build a private list of open points, ordered so that earlier answers unlock later ones. Look for:

| Area | Examples |
|---|---|
| **Goal** | What problem is solved? For whom? How is success measured? |
| **Scope** | What is in, what is explicitly out, what is the smallest useful version? |
| **Assumptions** | What is being taken for granted that could be false? |
| **Constraints** | Deadlines, budget, compatibility, performance, compliance |
| **Design choices** | Data model, interfaces, ownership, alternatives not considered |
| **Edge cases & failure** | Empty, huge, concurrent, invalid, partial-failure, rollback |
| **Dependencies** | Other teams, services, migrations, people who must agree |
| **Risk** | What breaks, who notices, how to undo it |
| **Verification** | How will we know it works? What gets tested? |

Skip areas that do not apply. Prioritize the questions whose answers change the most.

---

### Step 3 — Ask, one question at a time

For each question:

1. Ask **one** question. Never send a list.
2. Explain in one line **why it matters** (what it decides or what goes wrong if ignored).
3. Offer **your recommended answer** and, when useful, 2–3 concrete options with their trade-offs.
4. Wait for the user's answer.

Format:

```text
Q3 — Scope

What happens to existing sessions when the OAuth switch goes live?

Why it matters: forcing a global logout affects every active user at once.

Recommendation: keep legacy sessions valid until they expire (max 7 days per
src/auth/session.ts:42), and issue OAuth sessions only on new logins.

Options:
  a) Keep legacy sessions until expiry (recommended)
  b) Force logout at launch
  c) Migrate sessions silently on next request
```

Use the host's interactive question tool when available; otherwise ask in plain text.

---

### Step 4 — Follow the answers

- **Dig deeper** when an answer is vague ("we'll handle it later", "it should be fine"): ask for the specific case, number, or owner.
- **Challenge** answers that contradict the context, earlier answers, or the code — quote the conflicting source.
- **Branch** into new questions an answer opens up; drop questions an answer made irrelevant.
- **Accept** "I don't know" — record it as an open question and move on.
- Stay in the role of interviewer: don't start designing or implementing the solution.

---

### Step 5 — Know when to stop

Stop when any of these is true:

- Every high-impact point on the list is decided or explicitly parked.
- The user says stop, enough, or done.
- New questions only cover minor details.

As a guide: `quick` sessions ≈ 5 questions, normal ≈ 10, deep ≈ 20. Check in briefly every ~8 questions ("Keep going on edge cases, or wrap up?").

---

### Step 6 — Summarize

End with a concise summary the user can paste into a plan, ticket, or PR:

```text
## Grill summary — Migrate auth to OAuth

### Decisions
- Legacy sessions stay valid until expiry; OAuth only on new logins.
- Google and GitHub providers at launch; SAML is out of scope.

### Assumptions to verify
- The user table's `email` column is unique (not enforced in the schema today).

### Open questions
- Who owns the OAuth app credentials in production? (owner: TBD)

### Risks
- Account linking for users with the same email on two providers.

### Suggested next step
- Write the migration plan for the `users` table, then build the login flow.
```

Do not write the summary to a file unless the user asks.

---

## Rules

- **One question per message.** No questionnaires.
- **Ground every question** in the provided context or the code; cite files and lines when relevant.
- **Always give a recommendation** — the user should be able to answer "yes, go with that".
- **Be direct, not hostile.** Challenge the idea, not the person.
- **Never invent facts** about the codebase or the domain; say what you checked and what you couldn't find.
- **Read-only.** Never edit files, run migrations, or take actions during the session.
