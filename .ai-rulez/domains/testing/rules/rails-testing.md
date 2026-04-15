---
priority: high
domain: testing
---

# RSpec Testing Guidelines (Project-Specific)

## RSwag Contract Specs

For every API endpoint, create a spec in `spec/requests/api/v1/` using RSwag DSL.

```ruby
require 'swagger_helper'

RSpec.describe 'api/v1/widgets', type: :request do
  path '/api/v1/widgets' do
    get 'List widgets' do
      operationId 'listWidgets'
      tags 'Widgets'
      produces 'application/vnd.api+json'
      parameter name: :page, in: :query, type: :integer
      parameter name: :per_page, in: :query, type: :integer

      response '200', 'widgets found' do
        schema type: :object,
          properties: {
            data: { type: :array, items: { '$ref' => '#/components/schemas/Widget' } },
            meta: {
              type: :object,
              properties: {
                page: { type: :integer },
                per_page: { type: :integer },
                total: { type: :integer },
                total_pages: { type: :integer }
              }
            }
          }
        run_test!
      end
    end
  end
end
```

## Graphiti Resource Specs

Test custom filters and sorting in `spec/resources/` using `graphiti_spec_helpers`.

## General Guidelines
- Use FactoryBot for test data.
- One expectation per example.
- Run `bundle exec rake rswag:specs:swaggerize` to update `openapi.json`.
