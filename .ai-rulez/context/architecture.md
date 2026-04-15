---
priority: critical
domain: backend
---

# Wrapbook Projector – Full‑Stack Architecture

Rails 7.1 API‑only app serving JSON:API compliant responses, with a Next.js 16 frontend.

## ⚠️ CRITICAL: Serialization Architecture

This project uses **MANUAL JSON:API serialization**, NOT full Graphiti responders.

- `BaseController` includes `JsonapiSerialization` and calls `serialize_resource` / `serialize_collection`.
- Graphiti resources are used **only** for schema introspection and attribute whitelisting.
- **Filters defined in resources are NOT applied automatically** — `BaseController#apply_filters` must be wired explicitly.
- **`?include=` is NOT handled automatically** — requires custom logic in `JsonapiSerialization`.
- **NEVER** add `render jsonapi:` calls or manually parse `params[:include]` in controllers.

**Always confirm serialization style with `@preflight-check` before every feature.**

## Tech Stack

| Layer | Technology |
|---|---|
| Ruby | 3.2.2 |
| Rails | 7.1.2 |
| Database | SQLite3 (dev/test) · PostgreSQL (production‑ready) |
| Pagination | Pagy (default 20, max 100 · `page` + `per_page` params) |
| API Docs | RSwag / OpenAPI 3.0 |
| Serialization | Manual JSON:API (BaseController concerns) |
| Testing | RSpec + RSwag contract specs + Graphiti resource specs |
| Frontend | Next.js 16 (App Router) · React 19 |
| UI | Ant Design 5.x + @ant‑design/pro‑components |
| Forms | @rjsf/antd (schema‑driven from OpenAPI) |
| Server State | TanStack Query v5 |
| Client State | Zustand (theme + sidebar only) |
| API Client | @hey‑api/openapi‑ts generated SDK |
| Testing (FE) | Vitest (unit) + Playwright (E2E) |
| Package Manager | pnpm |

## Key Directories

```
app/controllers/api/v1/           # Controllers (all inherit BaseController)
app/controllers/concerns/api/v1/  # JsonapiActions · JsonapiSerialization · PagySupport
                                  # NestedResource · JsonapiErrorHandling · Serviceable
app/models/                       # ActiveRecord models (acts_as_paranoid soft‑delete)
app/resources/                    # Graphiti resources (schema/whitelist only)
app/services/                     # Orchestrators (ApplicationOrchestrator) + service objects
spec/requests/api/v1/             # RSwag contract specs
spec/resources/                   # Graphiti resource unit specs
spec/services/                    # Service/orchestrator unit specs
public/api-docs/v1/               # Generated openapi.json (via rails rswag:specs:swaggerize)
frontend/app/                     # Next.js App Router pages
frontend/src/api/generated/       # Generated TypeScript SDK (gitignored)
frontend/src/features/            # Feature modules with custom React Query hooks
frontend/src/components/          # ResourceWorkspace · ResourceTable · ResourceForm · AppShell
frontend/src/config/              # resources.ts (ResourceMeta) · navigation.ts
```

## Core Entities

| Model | Fields | Relationships |
|---|---|---|
| User | name, email | many‑to‑many Company via companies_users |
| Company | name | has_many users |
| Project | name, start_date, end_date | has_many tasks |
| Task | name, due_date, completed_at | belongs_to project |

## API Endpoints

```
GET/POST        /api/v1/companies
GET/PATCH/DELETE /api/v1/companies/:id
GET/POST        /api/v1/companies/:company_id/members
DELETE          /api/v1/companies/:company_id/members/:id
GET/POST        /api/v1/users
GET/PATCH/DELETE /api/v1/users/:id
GET/POST        /api/v1/projects
GET/PATCH/DELETE /api/v1/projects/:id
GET/POST        /api/v1/tasks
GET/PATCH/DELETE /api/v1/tasks/:id
GET             /api-docs           (Swagger UI)
GET             /api-docs/v1/openapi.json
```

## Development Workflow

```bash
rails server -p 3000          # Rails API
cd frontend && pnpm dev       # Next.js on :3001
open http://localhost:3001    # App
open http://localhost:3000/api-docs  # Swagger UI
```

## Development Principles

1. **TDD First** — failing RSwag spec before any implementation.
2. **Skinny controllers** — all CRUD via BaseController; custom logic in concerns or orchestrators.
3. **Graphiti resources for schema only** — attributes, types, writable flags. Not responders.
4. **Consistent JSON:API** — `{ data: ... }` for success; index adds `meta` with pagination.
5. **Error handling** — `JsonapiErrorHandling` concern rescues `RecordNotFound`, `RecordInvalid`. Never rescue manually in actions.
6. **Frontend: generated client only** — all API calls via `@hey-api` SDK. Manual `fetch` is forbidden.
7. **Frontend: server state in React Query** — never fetch in components. Custom hooks in `src/features/[resource]/hooks/`.
8. **Conditional migrations** — always use `unless column_exists?` to avoid duplicate column errors.
9. **Fixed dates in specs** — use `'2020-01-01'` for past‑date validations, never relative dates.
10. **Regenerate OpenAPI after every API change** — `bundle exec rails rswag:specs:swaggerize`.
