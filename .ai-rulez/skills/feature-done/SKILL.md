---
name: feature-done
description: Finalize a feature after all tests pass – update Swagger docs, generate commit message, and clean up.
---
# feature-done

The feature is complete and all tests pass. Perform final steps.

## Steps

1. **Update Swagger documentation**:
   - Run `bundle exec rake rswag:specs:swaggerize` to regenerate `swagger/v1/swagger.json`.
2. **Verify OpenAPI changes**:
   - Check that the new endpoints and schemas appear correctly in the generated spec.
3. **Generate commit message**:
   - Summarize the changes made (models, resources, specs) in a conventional commit format.
   - Example: `feat(api): add Project-Tasks relationship with cascade delete and include support`
4. **Run a final test suite** to ensure nothing broke.
5. **Report completion** with:
   - Files changed
   - New endpoints added
   - How to use the feature (e.g., `?include=tasks`)

## Output
- Commit message ready to use.
- Summary of changes.
