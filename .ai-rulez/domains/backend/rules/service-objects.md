---
priority: high
domain: backend
---

# Service Layer – Orchestrator Pattern

Business logic is extracted into **orchestrators** (`app/services/`) following a lightweight Flowlight-inspired pattern.

## Base Orchestrator (`ApplicationOrchestrator`)

Provides:
- `crud_actions` macro to define standard CRUD action sequences.
- Default actions: `validate`, `save`, `destroy_record`.
- Graphiti resource integration for writable attribute whitelisting.
- JSON:API error formatting.

## Concrete Orchestrator Example

```ruby
# app/services/company_orchestrator.rb
class CompanyOrchestrator < ApplicationOrchestrator
  crud_actions

  # Override or add custom actions as needed
  # def validate(context)
  #   # custom validation logic
  # end
end
```

## Controller Integration (`Serviceable` Concern)

```ruby
module Api::V1
  class CompaniesController < BaseController
    include Serviceable

    self.resource_class = CompanyResource
    self.model_class = Company

    service_orchestrator CompanyOrchestrator
  end
end
```

The `Serviceable` concern automatically routes `create`, `update`, and `destroy` through the orchestrator.
`index` and `show` remain handled by `BaseController`.

## Testing

Orchestrators are unit tested in `spec/services/`. Use the `.call` interface:

```ruby
result = CompanyOrchestrator.call(resource: company, params: params, action: :create)
expect(result[:success]).to be true
```

## When to Use

- **Always** for create, update, destroy actions (via `Serviceable`).
- Add custom business logic by overriding action methods in the concrete orchestrator.
- Keep orchestrators thin; extract complex workflows into separate service objects only when necessary.
