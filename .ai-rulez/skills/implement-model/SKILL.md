---
name: implement-model
description: Add ActiveRecord model associations, validations, and callbacks following project patterns.
---
# implement-model

Modify Rails models to add associations, validations, scopes, and business logic.

## 🚨 MANDATORY PRE-FLIGHT: Check Actual Database Before Migration 🚨

**Do not rely solely on `db/schema.rb` – it may be stale.**

1. **Verify the column exists in both development and test databases**:
   ```bash
   rails runner "puts {ModelName}.column_names.include?('{column_name}')"
   RAILS_ENV=test rails runner "puts {ModelName}.column_names.include?('{column_name}')"
   ```
2. If the column **already exists in both**, **DO NOT** create a migration.
3. If it exists only in test, create a migration to add it to development.
4. If it exists only in development, run `RAILS_ENV=test rails db:migrate`.

## Project Conventions
- Soft deletion via `acts_as_paranoid`.
- Use `dependent: :destroy` for cascading deletes.
- For `null: false` foreign keys:
  - The `belongs_to` association should **not** be `optional: true`.
  - Factories **must** create the associated record.
- **Foreign keys**: If using `dependent: :destroy`, avoid `on_delete: :cascade`.

## Handling Duplicate Columns
If a column already exists in the database but the migration fails, use a conditional migration:
```ruby
class AddProjectIdToTasks < ActiveRecord::Migration[7.2]
  def change
    unless column_exists?(:tasks, :project_id)
      add_column :tasks, :project_id, :bigint
    end
  end
end
```

## Writing Validations for JSON:API Error Responses

- Use custom validation methods for complex rules (e.g., `validate :due_date_not_in_past`).
- Error messages should be concise and user‑friendly.
- The `ApplicationOrchestrator` (or `BaseController` error handling) automatically formats errors into JSON:API format with `source.pointer`.
- Example:
  ```ruby
  def due_date_not_in_past
    return if due_date.blank? || due_date >= Date.today
    errors.add(:due_date, 'cannot be in the past')
  end
  ```

## Debugging Validation Failures
If a validation spec unexpectedly returns a 201 instead of 422, verify the validation logic directly in the Rails console:
```bash
rails runner "task = Task.new(name: 'Test', due_date: '2020-01-01'); puts task.valid?; puts task.errors.full_messages"
```
**Always use a fixed past date** like `'2020-01-01'` in tests and console checks to avoid false positives due to the current system date.

## Steps

1. **Check actual database** – confirm the change is needed in both environments.
2. Open the model file.
3. Add/update associations.
4. Add validations.
5. If a migration is needed, use `column_exists?` to make it idempotent.
6. Update factories to include required associations.
7. Update specs that create records to use factories or include the association.

## Output
- List of files changed.
- Migration commands (only if actually needed, with conditional logic).
- Any factory or spec updates required.
