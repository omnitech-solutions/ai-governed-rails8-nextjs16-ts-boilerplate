---
priority: high
domain: frontend
---

# Frontend Architecture (Next.js + Ant Design)

This project includes a Next.js 16 frontend located in `/frontend` that consumes the Rails JSON:API.

## Tech Stack
- **Framework:** Next.js 16 (App Router) with React 19
- **UI Library:** Ant Design 5.x + @ant-design/pro-components
- **Forms:** @rjsf/antd with schema‑driven generation from OpenAPI
- **Server State:** TanStack Query v5 – all API calls go through generated hooks
- **Client State:** Zustand – used **only** for theme and sidebar collapsed state
- **HTTP Client:** @hey-api/openapi-ts generated SDK
- **Styling:** CSS Modules + global Ant Design theme
- **Testing:** Vitest (unit/component) + Playwright (E2E)

## Directory Structure
```
frontend/
├── app/                    # Next.js App Router pages (companies, users, projects, tasks)
├── src/
│   ├── api/generated/      # OpenAPI generated SDK (gitignored, run `pnpm generate:api`)
│   ├── components/         # Shared generic components (ResourceTable, ResourceForm, Pagination, AppShell)
│   ├── config/             # Resource metadata and navigation configuration
│   ├── features/           # Feature modules (companies, users, projects, tasks)
│   │   └── [resource]/hooks/  # Custom React Query hooks wrapping generated SDK
│   ├── lib/                # JSON:API adapter, query client, generated query helpers
│   ├── stores/             # Zustand stores (theme-store, sidebar-store)
│   └── types/              # Shared TypeScript types
```

## Core Principles
- **Server State in React Query:** Never fetch data in components; always use custom hooks.
- **Client UI State in Zustand:** Only theme and sidebar state belong in Zustand. No React Context for data flow.
- **Schema‑Driven Forms:** All create/edit forms are rendered via `ResourceFormDialog` using JSON Schema from OpenAPI.
- **Generated API Client:** All API calls go through the generated `@hey-api` client. Manual `fetch` is forbidden.
- **Component Reusability:** `ResourceWorkspace`, `ResourceTable`, and `ResourceForm` are generic and work for any resource.
