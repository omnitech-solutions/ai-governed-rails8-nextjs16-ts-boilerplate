---
name: red
aliases: [failing-test, write-test]
description: Write a failing RSwag or RSpec test for the described requirement.
targets: [claude, cursor, windsurf]
---
# /red – Write a Failing Test (TDD)

I need a failing test for: **{{ARGUMENTS}}**

Invoke the `@write-api-spec` skill to create a single, well‑structured test that:
- For API endpoints: uses RSwag DSL in `spec/requests/api/v1/`.
- For services/models: uses plain RSpec.
- Uses FactoryBot for test data.
- Follows the project's JSON:API response format (data/errors/meta).
- Currently **fails** because the feature isn't implemented yet.

**⚠️ CRITICAL:** Avoid RSpec reserved matcher names (`include`, `have`, `be`, `expect`, `match`, `raise`, `respond_to`, `satisfy`) as RSwag parameters. For `?include=`, use a `before` block.

Do **not** write implementation code. Only the test.

After the test is written, run `rspec spec` to confirm it fails with the expected error.
