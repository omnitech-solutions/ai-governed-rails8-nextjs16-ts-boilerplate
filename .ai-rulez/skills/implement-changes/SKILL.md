---
name: implement-changes
description: Coordinate the implementation of models and resources for a feature.
---
# implement-changes

Given a feature description, delegate to specialized skills to make the code changes required to pass the failing spec.

## Workflow

1. **Analyze the spec changes** from `@write-api-spec`. Determine what models and resources need updates.
2. **Model changes**: Call `@implement-model` with specific instructions about associations, validations, etc.
3. **Resource changes**: Call `@implement-resource` to add attributes, filters, and relationships. **Remind explicitly: Do not add custom include serialization code.**
4. If a new endpoint or controller action is needed (beyond standard CRUD), call `@implement-endpoint`.
5. If business logic is complex, call `@implement-service` to create a service object.

## Important
- This skill is a coordinator; it should not write code itself. It should issue instructions to sub-skills.
- Always verify that `@implement-resource` did not touch `JsonapiSerialization`.
