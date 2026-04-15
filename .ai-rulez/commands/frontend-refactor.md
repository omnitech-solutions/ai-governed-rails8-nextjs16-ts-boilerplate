---
name: frontend-refactor
aliases: [fe-refactor, clean-ui]
description: Refactor frontend code – improve component structure, reduce duplication, or optimize performance.
targets: [claude, cursor, windsurf]
---
# /frontend-refactor – Refactor Frontend Code

Refactor the frontend code in **{{ARGUMENTS}}** (or the currently open file).

Guidelines:
- **Do not change external behavior** – all tests must stay green.
- Look for:
  - Duplicated logic that can be extracted into custom hooks or shared components.
  - Components that can be made more generic (e.g., a new `ResourceTable` column definition).
  - Inefficient re‑renders – add `React.memo` or optimize hook dependencies.
  - Direct `fetch` calls – replace with generated SDK hooks.
  - Zustand stores used for server state – migrate to React Query.
- Run `pnpm typecheck` and `pnpm lint` after changes.
- Ensure Playwright E2E tests still pass.
