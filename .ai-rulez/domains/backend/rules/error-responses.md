---
priority: high
domain: backend
---

# JSON:API Error Response Format

All error responses follow the JSON:API error structure.

## Standard Formats

**Validation Errors (422):**
```json
{
  "errors": [
    { "title": "Validation Error", "detail": "Name can't be blank", "status": 422 }
  ]
}
```

**Not Found (404):**
```json
{
  "errors": [
    { "title": "Not Found", "detail": "Company not found", "status": 404 }
  ]
}
```

## Implementation

The `JsonapiErrorHandling` concern (included in `BaseController`) handles:
- `ActiveRecord::RecordNotFound`
- `Graphiti::Errors::RecordNotFound`
- `ActiveRecord::RecordInvalid`
- `Graphiti::Errors::ValidationError`

Do not manually rescue in controller actions; rely on these handlers.
