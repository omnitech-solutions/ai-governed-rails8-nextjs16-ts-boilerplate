---
priority: high
domain: backend
---

# Rails Controller Guidelines (Project-Specific)

All API controllers should:
- Reside in `app/controllers/api/v1/`
- Inherit from `BaseController`
- Set `self.resource_class` and `self.model_class`
- Call `jsonapi_actions :all` (or specific actions) to enable CRUD

**Example:**
```ruby
module Api::V1
  class WidgetsController < BaseController
    self.resource_class = WidgetResource
    self.model_class = Widget
    jsonapi_actions :all
  end
end
```

**Nested Resources:** Include `NestedResource` concern and set `parent_model_class` and `association_name`.
```ruby
class CompanyMembersController < BaseController
  include NestedResource
  self.parent_model_class = Company
  self.association_name = :users
  # ...
end
```

**Do NOT** define manual CRUD actions unless absolutely necessary. Override `resource_scope` or use service objects for custom logic.
