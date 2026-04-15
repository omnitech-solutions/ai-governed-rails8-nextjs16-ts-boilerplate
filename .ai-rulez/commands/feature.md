---
name: feature
aliases: [new-feature, story]
description: Intelligently implement a JSON:API feature by analyzing the request and delegating to specialized skills.
targets: [claude, cursor, windsurf, gemini, codex]
---
# /feature – Implement a JSON:API Feature

I need to implement: **{{ARGUMENTS}}**

This command orchestrates the implementation by:
1. Analyzing the request and current codebase state.
2. Determining which architectural layers are affected.
3. Reading and following the appropriate layer‑specific skills in the correct order.
4. Ensuring tests are updated or created as needed.
5. Providing a verification summary so the developer can confirm the changes work correctly.

---

## 🔍 PHASE 1: Analyze & Scope

**MANDATORY: First, read and apply the `@preflight-check` skill.** Open `.ai-rulez/skills/preflight-check/SKILL.md` and follow its steps exactly. Do not skip this.

The preflight check will help you:
- Run existing request specs for the affected resource(s).
- Compare actual database state in **both test and development** environments.
- Determine whether the project uses **full Graphiti** or **manual JSON:API serialization**.
- Identify missing associations/attributes.
- Detect any schema drift.

Based on the preflight output:
- If **schema drift** is detected, read and follow the `@schema-sync` skill **before** proceeding.
- Note the **serialization style** – this determines how filters must be implemented.

Then identify affected layers:
- Route? → will need `@implement-route` skill
- Model/Migration? → will need `@implement-model` skill
- Graphiti Resource? → will need `@implement-resource` skill
- Orchestrator? → will need `@implement-orchestrator` skill
- Controller? → will need `@implement-controller` skill
- Specs? → will need `@write-api-spec` skill (new) or update existing specs directly.

---

## 🔴 PHASE 2: RED – Ensure Failing Test

**If the change introduces new behavior**, ensure there is a failing test.
- For new capabilities, read and follow the `@write-api-spec` skill.
- For modifications to existing endpoints, update the existing RSwag spec directly (still consult `@write-api-spec` for conventions).
- For model‑only changes, use plain RSpec.

Run the relevant spec(s) to confirm they fail for the expected reason.

---

## 🟢 PHASE 3: GREEN – Minimal Implementation

Implement **only** the changes required to pass the failing test(s). For each affected layer, open the corresponding skill file and follow its instructions:

| If this layer is affected... | Skill file to read and follow |
| :--- | :--- |
| Route | `.ai-rulez/skills/implement-route/SKILL.md` |
| Model / Migration | `.ai-rulez/skills/implement-model/SKILL.md` |
| Graphiti Resource | `.ai-rulez/skills/implement-resource/SKILL.md` |
| Orchestrator | `.ai-rulez/skills/implement-orchestrator/SKILL.md` |
| Controller | `.ai-rulez/skills/implement-controller/SKILL.md` |

**🚨 CRITICAL – Manual Serialization Projects Only:**
If the preflight check indicated **manual JSON:API serialization**, filters added to Graphiti resources will **not** be applied automatically. You **must** also:
1. Open `app/controllers/api/v1/base_controller.rb`.
2. Add or modify the `apply_filters` method (see `@implement-resource` skill for a complete example).
- [ ] If manual serialization and the feature requires `?include=`, I will add custom serialization logic in `JsonapiSerialization`.

**Important reminders:**
- Use conditional migrations (`column_exists?`) to avoid duplicate column errors.
- For `null: false` foreign keys, update factories to create the associated record.
- Do **NOT** manually implement `include` serialization.

After each change, run the affected spec(s). Once all specs pass, move to the next phase.

---

## 🔵 PHASE 4: REFACTOR

- Run `/refactor` on changed files.
- Run `/fix-n+1` if associations are serialized.
- Run `rubocop -A`.
- Optionally read and apply the `@code-reviewer` skill.

Re‑run the full test suite.

---

## 📋 PHASE 5: FINALIZE

1. Regenerate OpenAPI spec: `bundle exec rails rswag:specs:swaggerize`
2. Verify `public/api-docs/v1/openapi.json`.
3. Generate a commit message.
4. Use `/feature-done` for guided finalization.

---

## ✅ PHASE 6: VERIFY & DOCUMENT (MANDATORY)

Read and follow the `@verify-changes` skill to produce a verification summary.

---

## 🐛 Troubleshooting

### Truncated Test Output
If RSpec or RSwag output is truncated, redirect to a file and read it:
```bash
bundle exec rspec spec/requests/api/v1/tasks_spec.rb > /tmp/output.txt 2>&1
cat /tmp/output.txt
```

### Filter Failures (Manual Serialization)
- [ ] Verify `BaseController#resource_scope` calls `apply_filters`.
- [ ] Check that `params[:filter]` is passed correctly (use `let(:'filter[in_progress]') { true }`).
- [ ] Ensure test data is cleaned up (`Task.delete_all` in a `before` block).
- [ ] Confirm the filter operator is defined in the resource.

---

## 📋 Pre‑Flight Checklist for AI

Before writing any code, confirm:
- [ ] I have opened and followed `.ai-rulez/skills/preflight-check/SKILL.md`.
- [ ] I have noted the serialization style and any schema drift.
- [ ] I will update existing specs rather than create new ones unless a new resource is added.
- [ ] I will use RSwag DSL for API specs.
- [ ] I will produce/consume `application/vnd.api+json`.
- [ ] I will NOT manually implement `include` serialization.
- [ ] I will use conditional migrations.
- [ ] If using manual serialization, I will add filter application logic to `BaseController`.
- [ ] I will include a `response '422'` block in RSwag specs for validation failures, verifying the JSON:API error schema with `source.pointer`.
- [ ] I will use a **fixed past date** (e.g., `'2020-01-01'`) in validation error specs, not relative dates like `1.day.ago`.
- [ ] I will produce a verification summary using `@verify-changes`.