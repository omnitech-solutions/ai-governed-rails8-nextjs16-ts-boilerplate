---
priority: high
domain: frontend
---

# Frontend Code Quality Standards (TypeScript / React)

- All code must pass `tsc --noEmit` with `strict: true`. Run `pnpm typecheck` before committing.
- Run `pnpm lint` (Next.js ESLint config) before committing.
- Prefer functional components with hooks. Use `'use client'` only when genuinely needed.
- `React.memo`, `useCallback`, `useMemo` for expensive renders — not pre‑emptively.
- Avoid prop drilling; use React Query cache or composition.
