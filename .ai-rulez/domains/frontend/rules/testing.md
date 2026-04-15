---
priority: high
domain: frontend
---

# Frontend Testing Guidelines

## Unit & Component Tests (Vitest + React Testing Library)
- Test files co‑located with implementation: `*.test.ts(x)`.
- Mock API calls using MSW or by mocking the generated hooks.
- Test user interactions with `@testing-library/user-event`.
- Verify that forms display validation errors correctly.

## E2E Tests (Playwright)
- Located in `/frontend/e2e/`.
- Cover main flows: list → paginate → create → edit → delete.
- Test the company members management flow.
- Use page object pattern for maintainability.
