---
name: generate-api
aliases: [api-gen, sdk]
description: Regenerate the TypeScript SDK from the Rails OpenAPI spec.
targets: [claude, cursor, windsurf, codex]
---
# /generate-api – Regenerate Frontend API Client

Run this command whenever the Rails API endpoints or schemas change.

1. Ensure the Rails server is running on `http://localhost:3000`.
2. Execute from the `/frontend` directory:
   ```bash
   pnpm generate:api
   ```
3. The command will:
   - Fetch the latest `openapi.json` from `http://localhost:3000/api-docs/v1/openapi.json`.
   - Run `openapi-ts` to regenerate types and React Query hooks in `src/api/generated/`.
4. After regeneration, run `pnpm typecheck` to verify no breaking changes.
5. Commit the updated `openapi.json` and generated files.
