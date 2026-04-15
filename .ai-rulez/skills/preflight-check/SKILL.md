---
name: preflight-check
description: Mandatory gate before any feature work – verify specs, schema, serialization style, associations, and factories.
priority: critical
---
# preflight-check

**Run this before writing a single line of code.** Skipping this step is the #1 cause of wasted work in this project.

## Steps

### 1. Run Existing Request Specs
```bash
bundle exec rspec spec/requests/api/v1/{resource}_spec.rb --format documentation
```
- If specs **fail**: fix them in a separate commit before proceeding. Do not build on a broken baseline.
- If specs **pass**: note the count — you'll compare after the feature is done.

### 2. Detect Schema Drift (Development vs Test)
```bash
# Development DB
rails runner "puts {ModelName}.column_names.sort"

# Test DB
RAILS_ENV=test rails runner "puts {ModelName}.column_names.sort"
```
- **Test has extra columns** → create a migration to add them to development.
- **Development has extra columns** → run `RAILS_ENV=test rails db:migrate`.
- **`db/schema.rb` looks stale** → run `rails db:migrate` in development.
- **Drift detected** → run `@schema-sync` skill before proceeding.

### 3. Identify Serialization Pattern (CRITICAL — determines everything)
Open `app/controllers/api/v1/base_controller.rb` and check:

| What you see | Serialization style |
|---|---|
| `include JsonapiSerialization` + calls to `serialize_resource` / `serialize_collection` | **MANUAL** |
| `include JsonapiActions` + calls to `render jsonapi:` | **FULL_GRAPHITI** |
| *Neither / unsure* | **STOP — ask the developer to clarify before proceeding.** |

**This project uses MANUAL serialization.** Confirm and output:
```
Serialization style: MANUAL
```

Consequences of MANUAL style:
- Graphiti filters are defined in resource files but **NOT auto-applied**. `BaseController#apply_filters` must be wired.
- `?include=` is **NOT auto-handled**. Custom `JsonapiSerialization` logic required.
- Never add `render jsonapi:` anywhere.

### 4. Check for Missing Model Associations
For any foreign key column (e.g., `project_id`), verify:
- `belongs_to :project` exists in the model.
- `attribute :project_id, :integer` is defined and writable in the Graphiti resource.
- If `null: false`: `belongs_to` is NOT `optional: true`, and the factory creates the association.

### 5. Verify FactoryBot Factories
Run a quick sanity check that factories build without errors:
```bash
bundle exec rails runner "FactoryBot.build(:{resource_factory})"
```
Fix any `ArgumentError` or missing association before proceeding.

## Required Output Format
```
Preflight Check Results
=======================
Resource:            {ResourceName}
Existing specs:      PASS ({n} examples) | FAIL (list failures)
Schema drift:        NONE | (dev: [...], test: [...])
Serialization style: MANUAL
Missing associations: NONE | (list)
Factory issues:      NONE | (list)

PROCEED: YES | NO (reason)
```
