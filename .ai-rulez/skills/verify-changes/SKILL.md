---
name: verify-changes
description: Mandatory post-feature verification summary – prove the implementation is correct and complete.
priority: critical
---
# verify-changes

Produce this summary after **every** feature, no exceptions. It's your proof of work.

## Required Sections

### 1. What Changed
| File | Change |
|---|---|
| `app/resources/task_resource.rb` | Added `filter :in_progress, :boolean` |
| `app/controllers/api/v1/base_controller.rb` | Added `apply_filters` wiring in `resource_scope` |
| `spec/requests/api/v1/tasks_spec.rb` | Added `filter[in_progress]` response blocks (true + false) |
| `db/migrate/..._add_started_at_to_tasks.rb` | New `started_at datetime` column |

### 2. How to Verify
Provide the exact commands a developer can copy-paste:
```bash
# Run the affected specs
bundle exec rspec spec/requests/api/v1/tasks_spec.rb --format documentation

# Optional: manual curl
curl -s "http://localhost:3000/api/v1/tasks?filter[in_progress]=true&page=1&per_page=5" \
  -H "Accept: application/vnd.api+json" | jq .
```

### 3. Expected Results
- RSpec: All N examples pass, including X new examples added by this feature.
- Response shape for the new behaviour (show a real sample):
  ```json
  {
    "data": [
      { "id": "2", "type": "tasks", "attributes": { "name": "In Progress" } }
    ],
    "meta": { "page": 1, "per_page": 20, "total": 1, "total_pages": 1 }
  }
  ```

### 4. Proof of Correctness
- Paste the actual RSpec summary line: `N examples, 0 failures` 
- Confirm: `public/api-docs/v1/openapi.json` updated (new parameter/schema present)
- Confirm: No Bullet N+1 warnings in `log/test.log` for the affected resource

### 5. Known Limitations / Follow-ups (if any)
- E.g., "`?include=tasks` not yet supported — tracked in #123"
