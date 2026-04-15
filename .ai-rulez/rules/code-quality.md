---
priority: high
---

# Universal Code Quality Standards

These rules apply to **all** code changes, regardless of language or layer.

- **Minimal changes**: Make the smallest change that achieves the goal. No opportunistic refactoring, reformatting, or scope creep.
- **Read before write**: Open and understand existing files before editing. Match conventions already in place.
- **Explain non‑obvious decisions**: Briefly state why — not what — for any non‑trivial choice.
- **No dead code**: Delete unused code; never comment it out. Version control is the history.
- **Explicit errors**: Never swallow errors silently. Handle, propagate, or log with context.
