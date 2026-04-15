---
name: implement-controller
description: Create an API controller inheriting from BaseController with Serviceable concern.
---
# implement-controller

Create a controller for the new JSON:API resource.

## Project Conventions
- Controllers reside in `app/controllers/api/v1/`.
- Inherit from `BaseController`.
- Include `Serviceable` concern.
- Set `self.resource_class` and `self.model_class`.
- Declare `service_orchestrator`.

## Template

```ruby
# app/controllers/api/v1/{resource_name_plural}_controller.rb
module Api
  module V1
    class {ResourceNamePlural}Controller < BaseController
      include Serviceable

      self.resource_class = {ResourceName}Resource
      self.model_class = {ResourceName}

      service_orchestrator {ResourceName}Orchestrator
    end
  end
end
```

## Nested Controllers
For nested resources, include `NestedResource` and set `parent_model_class` and `association_name`.

## Output
- The created controller file.
