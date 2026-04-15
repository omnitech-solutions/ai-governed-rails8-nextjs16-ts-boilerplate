---
priority: critical
domain: backend
---

# Pagination – MANDATORY with Pagy

**Every `index` action MUST include pagination.** The `BaseController` automatically uses Pagy via `PagySupport`.

## Implementation (already in place)

```ruby
# app/controllers/concerns/api/v1/pagy_support.rb
module Api::V1
  module PagySupport
    extend ActiveSupport::Concern
    included { include Pagy::Backend }

    def pagy_metadata(pagy)
      { page: pagy.page, per_page: pagy.items, total: pagy.count, total_pages: pagy.pages }
    end
  end
end

# BaseController#resource_scope
def resource_scope
  @pagy, records = pagy(model_class.all, page: params[:page], items: params[:per_page])
  records
end
```

## Response Format

```json
{
  "data": [...],
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 42,
    "total_pages": 3
  }
}
```

## Configuration
- Default items: 20 (set in `config/initializers/pagy.rb`)
- Max items: 100
- Parameters: `page` and `per_page` query params.
