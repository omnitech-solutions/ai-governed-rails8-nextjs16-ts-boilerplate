---
name: fix-n+1
aliases: [nplusone, eager-load]
description: Analyze and fix N+1 queries in paginated JSON:API index actions, with thorough verification.
targets: [claude, cursor, windsurf]
---
# /fix-n+1 – Analyze and Fix N+1 Queries

Analyze **{{ARGUMENTS}}** for potential N+1 query issues.

Follow this systematic workflow to avoid unnecessary changes.

---

## 🔍 PHASE 1: Verify the N+1 Exists

**Do not assume an N+1 exists just because a relationship is present.** Verify first.

1. **Run the affected request spec** with Bullet enabled and capture the output:
   ```bash
   bundle exec rspec spec/requests/api/v1/{resource}_spec.rb
   ```
2. **Check `log/test.log`** for Bullet notifications:
   ```bash
   grep -i "bullet" log/test.log | tail -20
   ```
3. **If Bullet reports an N+1**, note the exact association and the call stack.
4. **If Bullet reports "AVOID eager loading detected"**, the relationship is **not** accessed during serialization. **Do not add eager loading.**
5. **If no Bullet warnings appear**, the current implementation is efficient. No action needed.

---

## 🔬 PHASE 2: Analyze Serialization Context

Before adding eager loading, confirm the relationship is actually serialized.

1. **Check the serializer** (`app/controllers/concerns/api/v1/jsonapi_serialization.rb`). Does it traverse relationships?
   - In this project, the manual serializer only processes **attributes**, not relationships.
2. **Check if the relationship is exposed** in the Graphiti resource (e.g., `has_many :companies`). Even if defined, it's only serialized when `?include=` is used.
3. **Check the request spec** – does it pass `?include=`? If not, the relationship is not being fetched.

**Conclusion:** If the relationship is not serialized in the current response, **eager loading is unnecessary** and may even trigger Bullet warnings.

---

## 🟢 PHASE 3: Apply Fix (Only If Needed)

If an actual N+1 is confirmed (Bullet warns about missing eager loading, and the relationship **is** serialized):

1. **Locate the `resource_scope` method** in the controller or `NestedResource` concern.
2. **Add eager loading** for the association:
   ```ruby
   def resource_scope
     base_scope = if parent
       parent.send(association_name)
     else
       model_class.all
     end
     # Eager load only if the relationship is serialized
     base_scope = base_scope.includes(:association_name)
     @pagy, records = pagy(base_scope, page: params[:page], items: params[:per_page])
     records
   end
   ```
3. **For nested resources** (e.g., `CompanyMembersController`), the scope is already filtered by the parent. Be cautious: Bullet may flag `includes` as redundant in this context.
4. **Run specs again** to confirm they pass and Bullet warnings are resolved.

---

## 📋 PHASE 4: If No Fix Needed

If the analysis concludes no N+1 exists, **do not change the code**. Provide a clear explanation:
- Which relationship was suspected.
- Why it is not serialized.
- What Bullet reported (if anything).
- Recommendation for future `?include=` support if desired.

---

## 🐛 Troubleshooting Truncated Bullet Errors

Bullet error messages in RSwag can be truncated. Use these techniques:
- Run the spec with `--format documentation` and capture full output.
- Dump the error to a file: `bundle exec rspec ... 2>&1 | tee /tmp/error.log`
- Inspect `log/test.log` for the full Bullet notification.

---

## 📋 Pre‑Flight Checklist for AI

Before making any changes, confirm:
- [ ] I have run the spec and captured Bullet output.
- [ ] I have determined whether the relationship is actually serialized.
- [ ] I have verified whether an N+1 warning is present (not an "AVOID eager loading" warning).
- [ ] I will only add `includes` if an N+1 is confirmed and the relationship is serialized.
- [ ] I will explain my findings if no change is needed.
