---
name: refactor
aliases: [clean, improve]
description: Refactor code – reduce duplication, improve naming, or extract concerns.
targets: [claude, cursor, windsurf, gemini]
---
# /refactor – Refactor Code (TDD)

Refactor the code for **{{ARGUMENTS}}** (or the currently open file).

Guidelines:
- **Do not change external behavior** – all specs must stay green.
- Look for:
  - Code duplication (DRY) – use shared examples for RSwag specs.
  - Complex methods that can be split.
  - Logic that belongs in a concern.
  - N+1 queries – use `/fix-n+1` to add eager loading.
  - Inconsistent naming or style (run `rubocop -A`).

Before making changes, run the specs to ensure a green baseline.
After refactoring, run specs again to confirm nothing broke.

Optionally, invoke `@code-reviewer` for a comprehensive review.

Explain your reasoning for each change.
