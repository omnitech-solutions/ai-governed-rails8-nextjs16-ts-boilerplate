---
name: migration
aliases: [add-migration, db-migrate]
description: Create a safe, reversible database migration.
targets: [claude, cursor, gemini, codex]
---
# /migration – Create a Database Migration

Generate a migration for: **{{ARGUMENTS}}** (e.g., "add status column to projects" or "create tasks table").

## ⚠️ Pre-Flight Schema Check (MANDATORY)
**Before generating any migration**, inspect `db/schema.rb` to verify the change is actually needed. If the column, index, or table already exists, do **NOT** create a duplicate migration—it will fail with `DuplicateColumn` error and waste time.

Requirements:
- The migration must be **reversible** (use `change` or provide `up`/`down`)
- Follow zero-downtime best practices:
  - For adding columns to large tables: add without default, then backfill, then add default in separate migration
  - Add indexes for foreign keys and columns used in `WHERE` clauses
- Use appropriate data types (e.g., `date` not `datetime` for `start_date`)
- **Foreign keys**: If using `dependent: :destroy` in the model, do **not** add `foreign_key: { on_delete: :cascade }`—choose one cascade method to avoid conflicts.

Generate the migration file content and show the command to run it: `rails db:migrate`.
Also run it in the test environment: `RAILS_ENV=test rails db:migrate`.

If this change affects models, note any updates needed to validations or factories.
