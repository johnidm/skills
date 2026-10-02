# Review Checklist

Use as a prompt for what to look at, not as a list to report against. Report only issues that apply to the changed code and survive verification.

## Correctness

- [ ] Conditions and boolean logic match the intent (inverted checks, `&&` vs `||`, missing `else`)
- [ ] Boundaries: off-by-one, empty collections, zero, negative numbers, max values
- [ ] Null, `undefined`, `None`, and missing keys are handled where they can occur
- [ ] Type coercion and comparison pitfalls (`==` vs `===`, string vs number, float equality)
- [ ] Date, time zone, and locale handling
- [ ] Async code is awaited; promises and futures are not dropped
- [ ] Early returns and exceptions leave state consistent
- [ ] Renamed or moved symbols are updated at every call site

## Security

- [ ] User input is validated and encoded for its sink (SQL, shell, HTML, path, URL, regex)
- [ ] Authorization is checked on every new endpoint, handler, or query — not just authentication
- [ ] No secrets, tokens, or credentials in code, logs, or error messages
- [ ] No sensitive data (PII, passwords, tokens) written to logs or responses
- [ ] File paths and URLs from input cannot escape their intended scope (traversal, SSRF)
- [ ] Deserialization, `eval`, template rendering, and dynamic imports are not fed untrusted data
- [ ] New dependencies are necessary, maintained, and pinned appropriately
- [ ] Cookies, CORS, and headers are not loosened unintentionally

## Reliability

- [ ] Errors are handled or propagated — not silently swallowed
- [ ] External calls have timeouts and sensible retry behavior
- [ ] Retried operations are idempotent
- [ ] Files, connections, locks, and subscriptions are released on every path
- [ ] Shared mutable state is safe under concurrency
- [ ] Failure messages give enough context to debug

## Data and contracts

- [ ] Migrations are reversible or have a rollback plan, and are safe on large tables
- [ ] Multi-step writes are wrapped in a transaction where partial writes would be harmful
- [ ] Public API, event, and schema changes are backward compatible, or the break is intentional and documented
- [ ] Default values and nullable columns are handled for existing rows

## Performance

- [ ] No queries or network calls inside loops (N+1)
- [ ] Result sets and in-memory collections are bounded or paginated
- [ ] New queries have supporting indexes
- [ ] Expensive work is not repeated on hot paths or every render

## Tests

- [ ] New or changed behavior has tests
- [ ] Tests assert the actual behavior, not just that code runs
- [ ] Edge cases and failure paths are covered for risky logic
- [ ] Tests were not deleted, skipped, or weakened without reason

## Maintainability

- [ ] Logic does not duplicate an existing helper in the codebase
- [ ] No dead code, leftover debug output, or commented-out blocks
- [ ] Names describe what things are and do
- [ ] Complexity is proportional to the problem
- [ ] Comments explain *why*, and still match the code
