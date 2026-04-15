---
name: fix-n-plus-1
description: Expert analysis and resolution of N+1 query issues in JSON:API Rails applications.
priority: high
---
# fix-n-plus-1 Skill

You are an expert at diagnosing and fixing N+1 queries in Rails JSON:API applications. Your goal is to ensure efficient database access without adding unnecessary eager loading.

## Core Principles

1. **Verify before fixing.** Never assume an N+1 exists just because a relationship is present.
2. **Understand the serialization context.** In manual JSON:API setups, relationships are **not** serialized unless explicitly requested via `?include=`.
3. **Respect Bullet's guidance.** "AVOID eager loading" warnings mean the association is **not used** – do not add `includes`.
4. **Nested resources are special.** The scope is already filtered by the parent; eager loading may be redundant.

## Workflow

### Step 1: Gather Evidence
- Run the relevant request spec with Bullet enabled.
- Extract Bullet messages from `log/test.log`.
- Identify the exact association and the line of code triggering the query.

### Step 2: Analyze Serialization
- Examine `JsonapiSerialization` concern. Does it recursively serialize relationships? (In this project, it does **not**.)
- Check the corresponding Graphiti resource for `has_many` or `belongs_to`. Even if defined, they are only used when `params[:include]` is present.
- Review the request spec – does it pass `?include=`?

### Step 3: Decision Tree
```
Is Bullet reporting "N+1 Query detected"?
├── No → No action needed. Explain why.
└── Yes → Is the relationship serialized?
    ├── No → Bullet may be flagging a potential issue for future `?include=` use. Document that eager loading is not currently required.
    └── Yes → Proceed to add eager loading.
```

### Step 4: Implement Eager Loading (if needed)
- Override `resource_scope` in the controller.
- Use `.includes(:association)` on the base scope.
- Ensure pagination still works with `pagy`.
- Re-run specs to confirm Bullet warnings disappear.

### Step 5: Handle Nested Resource Nuances
- In controllers using `NestedResource`, the scope is `parent.send(association_name)`. Adding `includes` may still be beneficial if the serialized attributes reference the association, but Bullet might complain.
- If Bullet warns "AVOID eager loading", respect it and do not add `includes`.

## Common Pitfalls

- **Adding `includes` when the relationship is not serialized.** This adds overhead and triggers Bullet warnings.
- **Ignoring "AVOID eager loading" warnings.** Bullet is telling you the data isn't being used.
- **Not checking `log/test.log` for full Bullet details.** Truncated output in the console hides the true cause.
- **Assuming all relationships cause N+1.** Graphiti resources may define relationships for introspection only, not for default serialization.

## Example Analysis

**Scenario:** `CompanyMembersController#index` with `UserResource` having `has_many :companies`.

1. **Bullet output:** `AVOID eager loading detected: User => [:companies]`.
2. **Serialization check:** `JsonapiSerialization` only serializes attributes. The `companies` relationship is not included in the response.
3. **Conclusion:** No N+1 exists. Do not add `includes`.

## Output

Provide a concise report:
- Whether an N+1 was found.
- Why or why not.
- Recommended action (add eager loading, do nothing, or document for future `?include=` support).
