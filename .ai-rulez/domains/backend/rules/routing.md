---
priority: medium
domain: backend
---

# Routing Conventions

Routes are namespaced under `/api/v1/`.

```ruby
# config/routes.rb
Rails.application.routes.draw do
  mount Rswag::Api::Engine => '/api-docs'
  namespace :api do
    namespace :v1 do
      resources :companies do
        resources :members, only: [:index, :create, :destroy], controller: 'company_members'
      end
      resources :users
      resources :projects
      resources :tasks
    end
  end
  get '/api/v1/openapi.json', to: redirect('/api-docs/v1/openapi.json')
end
```

**Note:** `shallow: true` is not currently used; nested routes are fully qualified (e.g., `/companies/:company_id/members`).
