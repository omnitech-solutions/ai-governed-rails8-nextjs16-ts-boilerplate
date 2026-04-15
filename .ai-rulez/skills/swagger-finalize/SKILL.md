---
name: swagger-finalize
description: Regenerate OpenAPI documentation and prepare commit message.
---
# swagger-finalize

Finalize the feature by updating the OpenAPI spec and generating a commit message.

## Steps

1. **Regenerate OpenAPI spec**:
   ```bash
   bundle exec rails rswag:specs:swaggerize
   ```

2. **Verify the changes** in `public/api-docs/v1/openapi.json`.

3. **Generate a conventional commit message**:
   - Format: `feat(api): add {description}` 
   - Example: `feat(api): add in_progress filter to TaskResource` 

4. **Run the full test suite** to ensure nothing broke.

## Output
- Confirmation that `openapi.json` was updated.
- Suggested commit message.
