---
name: iw2-tour-code
description: >-
  Explains how a repository or feature works by tracing a real request,
  command, or event through the code, stop by stop, with file and line
  references. Use for codebase walkthroughs, onboarding, or questions about
  where or how behavior is implemented ("how does login work?", "where are
  emails sent?", "walk me through this repo"). Use when the user runs
  /tour-code, /iw2-tour-code, or /code-tour. Do not use for a code review or a
  README rewrite.
---

# Tour Code

Explains how code works by following one real execution path — a request, a command, or an event — from where it enters the system to where it produces its result. Every claim points to a line of code that was actually read.

## Usage

```text
/iw2-tour-code [subject] [--depth quick|standard|deep]
# or
/tour-code [subject]
/code-tour [subject]
```

- `subject` — optional. What to trace, for example:
  - a feature: `checkout`, `password reset`
  - an entry point: `POST /api/orders`, `cli sync --all`, `OrderCreated event`
  - a question: `where are invoices generated?`
  - *(empty)* — a tour of the whole repository through its most representative flow
- `--depth` — optional, defaults to `standard`:
  - `quick` — the main path in 5–8 stops, no branches
  - `standard` — the main path plus important branches, errors, and side effects
  - `deep` — adds configuration, middleware, background work, tests, and alternative paths

## When not to use

- **Code review** (finding bugs, judging quality) → use `iw2-review-code`.
- **README or docs rewrite** → handle as a documentation task, not a tour.
- **A one-line lookup** ("what file defines `User`?") → answer directly without a full tour.

---

## Workflow

### Step 1 — Pick a concrete subject to trace

A tour follows **one specific execution**, not a whole area in the abstract.

- If the user named an entry point, trace that.
- If they named a feature or asked a question, pick the most representative real trigger for it (e.g. "password reset" → `POST /auth/password-reset`).
- If no subject was given, pick the flow that best shows how the repository works (the main API request, the primary CLI command, the core job).
- State the chosen subject in one line at the top of the tour. If several triggers are equally plausible and the choice changes the answer, **ask** before tracing.

---

### Step 2 — Orient in the repository

Run the mapping script from this skill directory:

```bash
bash scripts/map-repo.sh [path]
```

It prints the languages, manifests, frameworks, top-level layout, and likely entry points. Then read:

- `README`, `CLAUDE.md`, `AGENTS.md`, or architecture docs, if present
- The manifest (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, …) for frameworks and scripts
- The app bootstrap file (where the server, CLI, or worker is created and wired)

Spend only enough time here to know where to start. Do not summarize the whole repository.

---

### Step 3 — Find the entry point

Locate where the subject enters the code. Typical places:

| Trigger | Where to look |
|---|---|
| HTTP request | Route tables, decorators (`@app.get`, `@Controller`), file-based routes (`app/`, `pages/api/`), router registration |
| CLI command | Command registration (`argparse`, `click`, `commander`, `cobra`), `bin/`, `cmd/`, `manage.py` commands |
| Event or message | Subscribers, consumers, `on(...)` handlers, queue/topic names, webhook handlers |
| Scheduled job | Cron configs, schedulers, worker definitions |
| UI action | Component event handlers → API client → backend route |

Search for the literal identifier (URL path, command name, event name) rather than guessing file names. If routing is dynamic, find where registration happens and show it.

---

### Step 4 — Trace the path

Follow the execution hop by hop, **reading each file** before describing it. At each stop, record:

- **Where** — `path:line` of the function or block
- **What happens** — one or two sentences in plain language
- **Data** — what goes in and out, and how its shape changes (request body → DTO → model → row)
- **Side effects** — database reads/writes, network calls, queues, files, caches, emails
- **Branches** — validation failures, auth checks, feature flags, error handling (for `standard` and `deep`)

Rules while tracing:

- Follow interfaces, dependency injection, and dynamic dispatch to the **concrete implementation** that runs. Show how you resolved it (e.g. "bound in `container.ts:31`").
- Skip trivial pass-through layers in one line rather than giving each its own stop.
- When the path crosses a boundary (HTTP call to another service, message on a queue), say so and note where the other side lives, if it is in this repository.
- When behavior depends on config or environment, name the setting and where it is read.
- If you cannot determine what runs next, say so explicitly — **never** fill gaps with guesses.

When it is cheap and safe, confirm the path: run an existing test that covers it, or read the test to see the expected behavior. Never run commands with side effects (migrations, external calls, writes to real data).

---

### Step 5 — Write the tour

Use this format. Adjust length to the depth.

````markdown
## Tour: <subject>

**Traced:** `POST /api/orders` — creating an order from the checkout page
**In one sentence:** <what this flow does end to end>

### Map

```text
HTTP POST /api/orders
  → routes/orders.ts           (validate body)
  → OrderService.create        (price, stock check)
  → OrderRepository.insert     (DB transaction)
  → events.publish("order.created")
      → EmailWorker.onOrderCreated (confirmation email)
```

### Stops

**1. Route registration** — `src/routes/orders.ts:14`
The router binds `POST /api/orders` to `createOrder`, behind `requireAuth`.

**2. Request validation** — `src/routes/orders.ts:22`
The body is parsed with `OrderSchema`; invalid input returns 422 here and never reaches the service.

```ts
const input = OrderSchema.parse(req.body);
```

**3. ...**

### Side effects
- Writes `orders` and `order_items` in one transaction (`src/db/orders.ts:40`)
- Publishes `order.created` (`src/services/order.ts:88`)

### Where to change things
- Pricing rules → `src/services/pricing.ts`
- Validation → `src/schemas/order.ts`

### Gotchas
- <non-obvious behavior: implicit defaults, ordering, caching, magic config>

### Next tours
- <2–3 related flows worth tracing next>
````

Formatting rules:

- Use `path:line` references so they are clickable.
- Keep code snippets short (≤ 10 lines) and only where the code says something the prose cannot.
- For a **question**, answer it directly in the first two lines, then give the tour as supporting evidence.
- For **onboarding**, add a short "Key concepts" section before the stops defining domain terms the code relies on.
- Omit sections that have nothing to say (e.g. no side effects).

---

## Rules

- **Read-only.** Do not edit, refactor, or "fix" code during a tour.
- **Evidence only.** Every stop must cite code you actually read. Mark anything inferred as *(inferred)*.
- **One path at a time.** Trace the real flow; mention alternative paths briefly instead of touring all of them.
- **Not a review.** If you notice a likely bug, mention it in one line at the end and suggest `iw2-review-code`. Do not critique style or design.
- **Not a docs rewrite.** Do not produce or edit a README unless the user asks separately.
- Prefer plain language over jargon; explain domain terms the first time they appear.
