---
name: rubocop
aliases: [lint, style]
description: Run RuboCop and auto-correct safe offenses.
targets: [claude, cursor, codex]
---
# /rubocop – Run RuboCop Linter

Run RuboCop on **{{ARGUMENTS}}** (default: current file or `app/`).

1. Execute `rubocop {{ARGUMENTS}} --auto-correct`
2. Show a summary of corrections made and any remaining offenses
3. If there are offenses that cannot be auto-corrected, explain them and suggest manual fixes

This keeps the codebase consistent with the Ruby Style Guide.
