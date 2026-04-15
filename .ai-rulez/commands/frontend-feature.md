---
name: frontend-feature
aliases: [fe-feature, ui]
description: Implement a new frontend feature following SOLID principles with generated API hooks and Ant Design components.
targets: [claude, cursor, windsurf]
---
# /frontend-feature – Add a New Frontend Feature

I need to implement a new frontend feature: **{{ARGUMENTS}}**

Follow this workflow to maintain consistency with the existing codebase.

---

## 1. API Integration
- Ensure the Rails endpoint is documented in OpenAPI (`/api-docs/v1/openapi.json`).
- Run `pnpm generate:api` from `/frontend` to regenerate the TypeScript SDK.
- Create custom React Query hooks in `src/features/[resource]/hooks/` that wrap the generated hooks and apply JSON:API deserialization.

```ts
// src/features/widgets/hooks/use-widgets.ts
import { useQuery } from '@tanstack/react-query';
import { listWidgetsOptions } from '@/api/generated/@tanstack/react-query.gen';
import { deserialize, extractPaginationMeta } from '@/lib/json-api';

export function useWidgets(page = 1, perPage = 20) {
  return useQuery({
    ...listWidgetsOptions({ query: { page, per_page: perPage } }),
    select: (response) => ({
      data: deserialize<Widget>(response),
      meta: extractPaginationMeta(response),
    }),
  });
}
```

## 2. Resource Configuration
- Add resource metadata in `src/config/resources.ts`:
  - `ResourceMeta<T>` including `formSchema` (JSON Schema for RJSF), `tableColumns`, and labels.

## 3. Page Component
- Create a new page in `app/[resource]/page.tsx`.
- Use the generic `ResourceWorkspace` component:

```tsx
import { ResourceWorkspace } from '@/components/ResourceWorkspace';
import { widgetResource } from '@/config/resources';
import { useWidgets, useCreateWidget, useUpdateWidget, useDeleteWidget } from '@/features/widgets/hooks/use-widgets';

export default function WidgetsPage() {
  const { data, isLoading } = useWidgets();
  const createMutation = useCreateWidget();
  // ... other mutations

  return (
    <ResourceWorkspace
      resource={widgetResource}
      data={data}
      isLoading={isLoading}
      onCreate={createMutation.mutateAsync}
      onEdit={updateMutation.mutateAsync}
      onDelete={(record) => deleteMutation.mutate(record.id)}
    />
  );
}
```

## 4. Navigation
- Add the new resource to `src/config/navigation.ts` to appear in the sidebar.

## 5. Testing
- Write a Playwright spec for the CRUD flow.
- Write Vitest tests for the custom hooks and JSON:API adapter.

---

## Checklist
- [ ] OpenAPI spec updated and SDK regenerated.
- [ ] Custom hooks created with proper deserialization.
- [ ] Resource metadata added to `resources.ts`.
- [ ] Page component uses `ResourceWorkspace`.
- [ ] Navigation item added.
- [ ] Tests pass (`pnpm test` and `pnpm test:e2e`).
