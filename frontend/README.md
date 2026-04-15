# Frontend – Next.js 16 App Router

A modern Next.js 16 frontend with React 19, Ant Design UI, TanStack Query for server state, and auto-generated TypeScript SDK from OpenAPI spec.

## 📋 Project Overview

- **Framework**: Next.js 16 (App Router) with React 19
- **UI Library**: Ant Design 5.x + ProComponents
- **Forms**: `@rjsf/antd` – schema‑driven from OpenAPI
- **Server State**: TanStack Query v5 – all API calls go through generated hooks
- **Client State**: Zustand – **only** for theme and sidebar state
- **HTTP Client**: `@hey-api/openapi-ts` generated SDK
- **Testing**: Vitest (unit/component) + Playwright (E2E)
- **Package Manager**: pnpm

## 🚀 Quick Start

### Prerequisites
- **Node.js**: 18+
- **pnpm**: 8+
- **Backend API**: Rails server running on port 3000

### Setup
```bash
# Install dependencies
pnpm install

# Generate TypeScript SDK from OpenAPI spec (requires backend running)
pnpm generate:api

# Start development server
pnpm dev               # runs on http://localhost:3001
```

Frontend available at `http://localhost:3001`

## 🏛️ Architecture

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Framework** | Next.js 16 (App Router) | Server‑side rendering, routing, API routes |
| **UI Library** | Ant Design + ProComponents | Professional admin interface with dark theme |
| **Forms** | @rjsf/antd | Fully schema‑driven from OpenAPI definitions |
| **Server State** | TanStack Query v5 | Caching, synchronization, background refetching |
| **Client State** | Zustand | Theme and sidebar state only |
| **HTTP Client** | @hey-api/openapi-ts | Auto-generated TypeScript SDK |
| **Testing** | Vitest + Playwright | Unit/component + E2E coverage |

## 🧪 Testing

```bash
# Run unit/component tests
pnpm test

# Run tests with UI
pnpm test:ui

# Run E2E tests (Playwright)
pnpm test:e2e

# Type checking
pnpm typecheck

# Linting
pnpm lint

# Format code
pnpm format
```

## 📜 Available Scripts

| Script | Description |
|--------|-------------|
| `pnpm dev` | Start Next.js dev server on port 3001 |
| `pnpm build` | Build for production |
| `pnpm start` | Start production server |
| `pnpm lint` | Run ESLint |
| `pnpm typecheck` | Run TypeScript compiler (no emit) |
| `pnpm test` | Run Vitest unit/component tests |
| `pnpm test:ui` | Run Vitest with UI |
| `pnpm test:e2e` | Run Playwright E2E tests |
| `pnpm format` | Format all code with Prettier |
| `pnpm generate:api` | Pull OpenAPI spec from Rails and regenerate TypeScript SDK |

## 📁 Key Directories

```
frontend/
├── app/                      # App Router pages
│   ├── (dashboard)/          # Dashboard route group with layout
│   ├── layout.tsx           # Root layout
│   └── page.tsx             # Root page (redirects to /dashboard)
├── src/
│   ├── api/generated/        # OpenAPI generated SDK (gitignored)
│   ├── components/           # Shared generic components
│   │   ├── AppShell/        # Main layout with sidebar navigation
│   │   ├── ResourceTable/   # Generic table component
│   │   ├── ResourceForm/    # Generic form dialog
│   │   └── ResourceWorkspace/ # Generic CRUD workspace
│   ├── config/               # Resource metadata and navigation
│   │   ├── navigation.ts    # Sidebar navigation items
│   │   └── resources.ts     # Resource configuration
│   ├── features/             # Feature modules with custom hooks
│   ├── lib/                  # Utilities
│   │   ├── json-api.ts      # JSON:API adapter functions
│   │   └── query-client.tsx # TanStack Query configuration
│   └── stores/               # Zustand stores (theme, sidebar)
├── public/                   # Static assets
└── openapi-ts.config.ts      # OpenAPI generation configuration
```

## 🔧 Adding a New Frontend Feature

1. Ensure backend endpoint is documented in OpenAPI
2. Run `pnpm generate:api` to regenerate TypeScript SDK
3. Create custom React Query hooks in `src/features/[resource]/hooks/`
4. Add resource metadata to `src/config/resources.ts`
5. Create page component using `ResourceWorkspace`
6. Add navigation item to `src/config/navigation.ts`
7. Write tests (Vitest + Playwright)

## 📄 License

This project is for interview/development purposes only.
