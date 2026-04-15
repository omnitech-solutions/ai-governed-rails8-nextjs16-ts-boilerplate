---
name: write-api-spec
description: Write a failing RSwag request spec for a JSON:API endpoint following project conventions.
---
# write-api-spec

Write a request spec in `spec/requests/api/v1/` using the **RSwag DSL**.

## Project Conventions
- **Path prefix:** `/api/v1/` 
- **Content-Type:** `application/vnd.api+json` 
- **Pagination:** `page` and `per_page` query params.
- **Inclusion:** Use a `before` block for `include` parameter (avoid `parameter name: :include`).

## Test Data Cleanup (Important)
To prevent pollution from existing test data, **always** use `before` blocks to clean the relevant tables:
```ruby
before do
  Task.delete_all
  Project.delete_all
end
```
Or use **FactoryBot** with proper associations.

## Testing Validation Errors (422 Unprocessable Entity)
When adding or modifying model validations, include a `response '422'` block that tests the failure case.
The schema should include the `errors` array with `source.pointer`.

**⚠️ CRITICAL – Use Fixed Past Dates, Not Relative Dates**
Relative dates like `1.day.ago`, `Date.yesterday`, or `Date.today - 1` can evaluate to today if the system clock is skewed (e.g., in a future‑dated test environment). **Always use a fixed past date** like `'2020-01-01'` to guarantee the date is truly in the past.

```ruby
response '422', 'due_date in the past' do
  schema type: :object,
    properties: {
      errors: {
        type: :array,
        items: {
          type: :object,
          properties: {
            title: { type: :string },
            detail: { type: :string },
            status: { type: :integer },
            source: {
              type: :object,
              properties: {
                pointer: { type: :string }
              }
            }
          }
        }
      }
    }

  let(:task) { { name: 'My Task', due_date: '2020-01-01' } }

  run_test!
end
```
This ensures the contract validates the exact JSON:API error format, including the `source.pointer` that points to the invalid attribute.

## Writing Filter Specs (Nested Parameters)
When testing filters, you must use RSwag's nested parameter syntax. **Do not** use `let(:filter)` with a hash.

**Correct pattern:**
```ruby
parameter name: :'filter[in_progress]', in: :query, type: :boolean, required: false
let(:'filter[in_progress]') { true }
```

**Incorrect (will not work):**
```ruby
let(:filter) { { in_progress: true } }
```

## Boolean Filters: Test Both `true` and `false` 
For boolean filters, create **two separate `response` blocks** (or use `context` blocks) to test both values. This ensures the filter correctly includes/excludes records in both states.

```ruby
# Test true case
response '200', 'tasks filtered by in_progress = true' do
  let(:'filter[in_progress]') { true }
  # ... assertions for in-progress tasks only
  run_test!
end

# Test false case
response '200', 'tasks filtered by in_progress = false' do
  let(:'filter[in_progress]') { false }
  # ... assertions for NOT in-progress tasks
  run_test!
end
```

## Full Example: Filter Test
```ruby
response '200', 'tasks filtered by in_progress = true' do
  schema type: :object,
    properties: {
      data: { type: :array, items: { '$ref' => '#/components/schemas/Task' } },
      meta: { type: :object }
    }

  before do
    Task.delete_all
    Task.create!(name: 'Not Started', started_at: nil, completed_at: nil)
    Task.create!(name: 'In Progress', started_at: 1.hour.ago, completed_at: nil)
    Task.create!(name: 'Completed', started_at: 2.hours.ago, completed_at: 1.hour.ago)
  end

  parameter name: :'filter[in_progress]', in: :query, type: :boolean, required: false
  let(:'filter[in_progress]') { true }

  run_test! do |response|
    data = JSON.parse(response.body)['data']
    expect(data.size).to eq(1)
    expect(data.first['attributes']['name']).to eq('In Progress')
  end
end
```

## Debugging Truncated Output
If RSpec or RSwag output is cut off, redirect to a file and read it:
```bash
bundle exec rspec spec/requests/api/v1/tasks_spec.rb > /tmp/output.txt 2>&1
cat /tmp/output.txt
```

## Steps
1. Identify the resource and desired behavior.
2. Locate/create the spec file.
3. Write the `path` block with `operationId`, `tags`, `consumes`, `produces`, `parameters`.
4. Define `response` blocks with JSON:API schema references.
5. **For filters:** Use `parameter name: :'filter[name]'` and `let(:'filter[name]') { value }`.
6. **For boolean filters:** Include tests for both `true` and `false` values.
7. **For validation errors:** Include a `response '422'` block with the complete JSON:API error schema, verifying the `source.pointer`. **Always use fixed past dates like `'2020-01-01'`** – never relative dates.
8. **Always** include a `before` block to clean up test data.
9. Use `run_test!` and add custom assertions inside the block.
10. Ensure the spec fails initially (RED).

## Output
- The file path of the modified spec.
- Expected failure message.
