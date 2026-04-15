---
name: implement-resource
description: Add or update Graphiti resources with proper relationships and attributes, following project patterns.
---
# implement-resource

Modify Graphiti resource classes in `app/resources/` to define attributes, filters, pagination, and relationships.

## 🚨🚨🚨 CRITICAL RULE – READ THIS FIRST 🚨🚨🚨

**Graphiti automatically handles the `?include=` query parameter when you define relationships.**
- **NEVER** add custom serialization code for `include` in `JsonapiSerialization`.
- **NEVER** manually parse `params[:include]` in controllers or serializers.

---

## Determine Serialization Pattern (from `@preflight-check`)

- **Full Graphiti**: `BaseController` uses `render jsonapi: ...`. Filters and `include` work automatically via Graphiti responders.
- **Manual Serialization**: `BaseController` uses `JsonapiSerialization`. Both filters and `include` require **manual implementation** in the controller/serializer.

---

## Implementation Steps

1. Open the relevant resource file (e.g., `app/resources/project_resource.rb`).
2. If adding a relationship: `has_many :tasks` or `belongs_to :project`.
3. If adding a new attribute: `attribute :new_field, :string`.
4. **For foreign key columns**: Ensure the attribute is defined and writable: `attribute :project_id, :integer`.
5. **Adding a Filter**:

   **If using Full Graphiti:**
   ```ruby
   filter :in_progress, :boolean do
     eq { |scope, value| scope.where('started_at IS NOT NULL AND completed_at IS NULL') if value }
   end
   ```

   **If using Manual Serialization:**
   - Add the filter DSL (for OpenAPI introspection) as shown above.
   - **Additionally, you MUST add filter application logic to `BaseController`.** See the next section.

   **Important for Boolean Filters in Manual Serialization:**
   - RSwag passes boolean parameters as strings (`'true'` / `'false'`). Your filter block should handle both boolean and string values:
     ```ruby
     if value == true || value == 'true'
       # true condition
     else
       # false condition
     end
     ```
   - When the filter value is `false`, the `eq` operator will be called with `value == false`.
   - In the current manual serialization setup, `BaseController#apply_filters` only supports the `:eq` operator.
   - If you want `false` to have a specific behavior (e.g., exclude in‑progress tasks), you must handle it in the filter block:
     ```ruby
     filter :in_progress, :boolean do
       eq do |scope, value|
         if value == true || value == 'true'
           scope.where('started_at IS NOT NULL AND completed_at IS NULL')
         else
           scope.where('started_at IS NULL OR completed_at IS NOT NULL')
         end
       end
     end
     ```
   - If you leave the `if value` guard, `false` will return the unfiltered scope (i.e., all records).

---

## Adding `include` Support (Manual Serialization Only)

If the project uses manual serialization, `?include=` is not handled automatically. To support it:
1. Extend `JsonapiSerialization` to process `params[:include]`.
2. Serialize the requested relationships and add an `included` key to the response.
3. See the project's existing `serialize_included` method as a reference.

**Do not** add custom serialization code for `include` in full Graphiti projects.

---

## Manual Serialization: Adding Filter Application to BaseController

If the project uses manual serialization, filters defined in resources will **not** be applied automatically. You must modify `app/controllers/api/v1/base_controller.rb`:

```ruby
# In BaseController, add or modify the resource_scope and apply_filters methods:

def resource_scope
  scope = model_class.all
  scope = apply_filters(scope) if params[:filter].present?
  @pagy, records = pagy(scope, page: params[:page], items: params[:per_page])
  records
end

def apply_filters(scope)
  filters = params[:filter]
  return scope unless filters.is_a?(ActionController::Parameters)

  filters.each do |filter_name, value|
    filter_config = resource_class.filters[filter_name.to_sym]
    next unless filter_config

    # NOTE: This implementation currently only supports the :eq operator.
    # If additional operators (e.g., :gte, :lte) are needed, extend this method.
    operator = filter_config[:operators][:eq]
    if operator
      # Convert string 'true'/'false' to boolean if needed
      typed_value = if filter_config[:type] == :boolean
                      ActiveModel::Type::Boolean.new.cast(value)
                    else
                      value
                    end
      scope = operator.call(scope, typed_value)
    end
  end
  scope
end
```

---

## Verification
- The resource changes should be minimal and declarative.
- After implementing, the RSwag spec should pass.
