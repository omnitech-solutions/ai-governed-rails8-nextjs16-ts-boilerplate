---
priority: high
domain: backend
---

# Rails Model Guidelines

Best practices for ActiveRecord models in this project.

- **Validations**: Define all data integrity rules using ActiveRecord validations. These are used by `BaseController` to return 422 errors.
- **Associations**: Use `has_many`, `belongs_to`, `has_and_belongs_to_many` with appropriate `dependent` options.
- **Scopes**: Encapsulate reusable query logic in scopes.
- **Callbacks**: Use sparingly. Prefer service objects for complex workflows.
- **N+1 Queries**: Override `resource_scope` in controllers to `includes` necessary associations.
