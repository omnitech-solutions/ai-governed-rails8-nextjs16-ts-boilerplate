---
name: green
aliases: [implement, make-it-pass]
description: Implement the minimal code to make the failing test pass using layer‑specific skills.
targets: [claude, cursor, windsurf]
---
# /green – Minimal Implementation (TDD)

I need to implement the code to pass the failing spec for: **{{ARGUMENTS}}**

Invoke the following skills in order to build the minimal viable implementation:

1. **`@implement-route`** – Add the route to `config/routes.rb`.
2. **`@implement-model`** – Create the ActiveRecord model and migration (after verifying schema).
3. **`@implement-resource`** – Create the Graphiti resource with attributes and relationships.
4. **`@implement-orchestrator`** – Create the service orchestrator.
5. **`@implement-controller`** – Create the API controller.

After each step, run the specs to ensure progress.

**Important reminders:**
- Run migrations in the test environment: `RAILS_ENV=test rails db:migrate` 
- Do NOT manually implement `include` serialization; Graphiti handles it automatically.
- Pagination and JSON:API serialization are provided by `BaseController`.

Once all specs pass, move to the REFACTOR phase (`/refactor`).
