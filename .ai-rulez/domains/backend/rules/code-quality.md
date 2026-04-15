---
priority: high
domain: backend
---

# Backend Code Quality Standards (Ruby / Rails)

- Max 120 character line width. Run `rubocop -A` after every change.
- Functions ≤ 50 lines, cyclomatic complexity ≤ 20, nesting depth ≤ 4.
- Descriptive names — no abbreviations in public APIs (`context` not `ctx`, `repository` not `repo`).
- `frozen_string_literal: true` at the top of every file.
- Prefer `&:method_name` blocks for simple transforms. Use `then`/`yield_self` for chaining.
- No monkey‑patching in production. No `method_missing` without `respond_to_missing?`. No `eval` with user input.
