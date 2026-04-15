---
name: implement-orchestrator
description: Create a service orchestrator inheriting from ApplicationOrchestrator with crud_actions.
---
# implement-orchestrator

Create an orchestrator for the resource's business logic.

## Project Conventions
- Orchestrators reside in `app/services/`.
- Inherit from `ApplicationOrchestrator`.
- Call `crud_actions` for standard CRUD.
- Override `validate`, `save`, or `destroy_record` for custom logic.

## Template

```ruby
# app/services/{resource_name}_orchestrator.rb
class {ResourceName}Orchestrator < ApplicationOrchestrator
  crud_actions
end
```

## Output
- The created orchestrator file.
