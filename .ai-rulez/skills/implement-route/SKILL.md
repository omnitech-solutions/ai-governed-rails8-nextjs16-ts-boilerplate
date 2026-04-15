---
name: implement-route
description: Add a resource route to config/routes.rb following project conventions.
---
# implement-route

Add the route for the new JSON:API resource.

## Project Conventions
- Routes are namespaced under `namespace :api do namespace :v1 do`.
- Use `resources` for standard CRUD.
- Nested routes are fully qualified (e.g., `/companies/:company_id/members`).

## Implementation

Open `config/routes.rb` and add inside the `namespace :api do namespace :v1 do` block:
```ruby
resources :{resource_name_plural}
```

For nested resources, include the parent:
```ruby
resources :companies do
  resources :members, only: [:index, :create, :destroy], controller: 'company_members'
end
```

## Output
- The modified section of `routes.rb`.
