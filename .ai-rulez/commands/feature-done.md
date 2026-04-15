---
name: feature-done
description: Finalize a feature after all tests pass – regenerate OpenAPI docs, verify, and commit.
---
# feature-done

All tests are green. Perform the final steps to ship the feature.

## Steps

1. **Regenerate OpenAPI documentation**:
   ```bash
   bundle exec rails rswag:specs:swaggerize
   ```
   ⚠️ Use the Rails task — NOT `bundle exec rake rswag:specs:swaggerize` (deprecated path) and NOT the standalone `rswag` binary.
   Output: `public/api-docs/v1/openapi.json` 

2. **Verify OpenAPI changes**:
   - Confirm new endpoints, parameters, and schemas appear in `public/api-docs/v1/openapi.json`.
   - Check that filter parameters show correct types (e.g., `boolean`, not `string`).

3. **Run the full test suite** one final time:
   ```bash
   bundle exec rspec spec
   ```

4. **Generate a conventional commit message** summarising the change:
   ```
   feat(api): <description>
   ```
   Example: `feat(api): add in_progress filter to tasks with Pagy pagination` 

5. **Report completion** with:
   - Files changed (with one-line description each)
   - New or modified endpoints
   - Usage examples (e.g., `GET /api/v1/tasks?filter[in_progress]=true&page=1&per_page=20`)

## Output
- Ready-to-use commit message
- Completion summary
