---
name: schema-sync
description: Detect and resolve schema drift between development and test databases.
---
# schema-sync

Resolve inconsistencies between development and test database schemas.

## Steps

### 1. Compare Column Lists
```bash
# Development
rails runner "puts {ModelName}.column_names.sort"

# Test
RAILS_ENV=test rails runner "puts {ModelName}.column_names.sort"
```

### 2. Analyze Differences
- **Column in test but not development**: The migration is missing from development. Generate a migration to add it.
- **Column in development but not test**: Test DB is behind. Run `RAILS_ENV=test rails db:migrate`.
- **`db/schema.rb` doesn't match development**: Run `rails db:migrate` to update it.

### 3. Apply Fix
- For missing columns, create a migration with `column_exists?` check:
  ```ruby
  class AddMissingColumnsToTasks < ActiveRecord::Migration[7.2]
    def change
      add_column :tasks, :project_id, :bigint unless column_exists?(:tasks, :project_id)
      add_column :tasks, :started_at, :datetime unless column_exists?(:tasks, :started_at)
    end
  end
  ```
- Run migrations in both environments.

### 4. Verify Sync
Re‑run the column list comparison to confirm both environments match.

## Output
- Summary of drift detected.
- Migration content (if needed).
- Commands to run.
