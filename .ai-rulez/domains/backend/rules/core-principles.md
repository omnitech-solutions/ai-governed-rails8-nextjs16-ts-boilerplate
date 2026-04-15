---
priority: high
domain: backend
---

# Core Development Principles

These principles apply across the entire codebase.

- **TDD First**: Never write implementation code without a failing test (RED → GREEN → REFACTOR). Use RSwag for API endpoints, RSpec for services.
- **Skinny Controllers**: Controllers inherit from `BaseController` and declare `jsonapi_actions :all`. Custom logic goes in concerns or service objects.
- **Graphiti Resources for Schema**: Resources define attributes, types, and writable flags. They are not used for full responders yet.
- **Consistent JSON:API Responses**: All success responses use `{ data: ... }`; index responses include `meta` with pagination info.
- **Error Handling**: JSON:API error format via `JsonapiErrorHandling` concern (rescues RecordNotFound, RecordInvalid).
- **Commit Often**: Small, focused commits with Conventional Commit messages.
