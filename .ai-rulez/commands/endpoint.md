---
name: endpoint
aliases: [new-endpoint, api]
description: Add a new JSON:API endpoint using BaseController, Serviceable, and the orchestrator pattern.
targets: [claude, cursor, windsurf]
---
# /endpoint – Add a New JSON:API Endpoint

I need to add a new endpoint: **{{ARGUMENTS}}**

Follow this checklist based on the project's actual architecture:

1. **Route**: Add to `config/routes.rb` under the existing `namespace :api do namespace :v1 do` block.
   ```ruby
   resources :widgets
   ```

2. **Graphiti Resource**: Create `app/resources/widget_resource.rb` for schema introspection.
   ```ruby
   class WidgetResource < ApplicationResource
     self.type = 'widgets'
     attribute :name, :string
     attribute :created_at, :datetime, writable: false
     attribute :updated_at, :datetime, writable: false
   end
   ```

3. **Orchestrator**: Create `app/services/widget_orchestrator.rb`:
   ```ruby
   class WidgetOrchestrator < ApplicationOrchestrator
     crud_actions
   end
   ```

4. **Controller**: Create `app/controllers/api/v1/widgets_controller.rb`:
   ```ruby
   module Api::V1
     class WidgetsController < BaseController
       include Serviceable

       self.resource_class = WidgetResource
       self.model_class = Widget

       service_orchestrator WidgetOrchestrator
     end
   end
   ```

5. **Model**: Create `app/models/widget.rb` with appropriate validations and migrations.

6. **RSwag Spec**: Create `spec/requests/api/v1/widgets_spec.rb` using RSwag DSL.
   - Produces/consumes `application/vnd.api+json` 
   - Include pagination parameters for index
   - Reference schemas from `swagger_helper.rb` 

7. **Update `swagger_helper.rb`**: Add `Widget` and `WidgetRequest` schemas.

8. **Run specs**: `bundle exec rspec spec/requests/api/v1/widgets_spec.rb` 
9. **Generate OpenAPI spec**: `bundle exec rake rswag:specs:swaggerize`
