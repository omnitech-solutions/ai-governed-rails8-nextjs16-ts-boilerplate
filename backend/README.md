# Backend API – Rails 8.1 JSON:API

A production-ready Rails 8.1 backend serving JSON:API compliant responses with Graphiti resources, RSwag documentation, and comprehensive testing.

## 📋 Project Overview

- **Ruby**: 3.2.2
- **Rails**: 8.1
- **Database**: SQLite3 (development/test) · PostgreSQL (production-ready)
- **Pagination**: [Pagy](https://github.com/ddnexus/pagy) (default 20, max 100)
- **API Documentation**: [RSwag](https://github.com/rswag/rswag) (OpenAPI 3.0)
- **Serialization**: Manual JSON:API via `BaseController` concerns + Graphiti resource introspection
- **Testing**: RSpec with RSwag contract specs and Graphiti resource specs
- **Authentication**: [Warden](https://github.com/hassox/warden) (placeholder implementation)
- **Authorization**: [Pundit](https://github.com/varvet/pundit) (policy-based authorization)
- **Soft Deletion**: [Paranoia](https://github.com/railsware/paranoia) (soft delete for all models)
- **Structured Logging**: [Lograge](https://github.com/roidrage/lograge) (JSON logs in production)
- **N+1 Detection**: [Bullet](https://github.com/flyerhzm/bullet) (development query analysis)

## 🚀 Quick Start

### Prerequisites
- **Ruby**: 3.2.2
- **SQLite3**: (for development/testing)
- **Node.js**: 18+ (for pnpm workspace)

### Setup
```bash
# Install dependencies
bundle install

# Create database (SQLite3 for dev/test)
rails db:create

# Run migrations
rails db:migrate

# (Optional) Seed data
rails db:seed

# Verify everything works
bundle exec rspec spec

# Start server
rails server            # runs on http://localhost:3000
```

API available at `http://localhost:3000/api/v1/`  
Interactive docs at `http://localhost:3000/api-docs`

## 🏛️ Architecture

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Controllers** | `BaseController` + concerns | Reusable CRUD, JSON:API serialization, pagination, error handling |
| **Resources** | Graphiti | Schema introspection (attributes, types, writable flags) – *not full responders* |
| **Pagination** | Pagy | Consistent `meta` in index responses |
| **Testing** | RSwag (contract), RSpec (unit) | OpenAPI spec auto‑generation + business logic coverage |
| **Docs** | Swagger UI | Served at `/api-docs` from `public/api-docs/v1/openapi.json` |

## 🔐 Foundational Gems

### Authentication (Warden)
- **Purpose**: Rack-based authentication middleware
- **Current State**: Placeholder implementation in `config/initializers/warden.rb`
- **Usage**: `current_user` returns `nil` (backward compatible)

### Authorization (Pundit)
- **Purpose**: Policy-based authorization
- **Current State**: All policies return `true` for all actions (backward compatible)
- **Usage**: Policies in `app/policies/`

### Soft Deletion (Paranoia)
- **Purpose**: Soft delete records instead of permanent deletion
- **Current State**: All models have `acts_as_paranoid` and `deleted_at` columns
- **Usage**: `destroy` sets `deleted_at`. Access with `Model.unscoped` to include deleted records.

### Structured Logging (Lograge)
- **Purpose**: Single-line JSON logs for production
- **Configuration**: Enabled in `config/environments/production.rb`

### N+1 Query Detection (Bullet)
- **Purpose**: Detect N+1 query performance issues
- **Configuration**: Enabled in `development.rb` (logs) and `test.rb` (raises errors)

## 🧪 Testing

```bash
# All tests (fast, excludes RSwag specs)
bundle exec rspec --exclude-pattern "spec/requests/**/*_swagger_spec.rb"

# Only RSwag contract tests
bundle exec rspec spec/requests/api/v1/

# Regenerate OpenAPI spec after changing RSwag tests
bundle exec rake rswag:specs:swaggerize
```

## 📜 Available Scripts

| Script | Description |
|--------|-------------|
| `pnpm dev` | Start Rails server on port 3000 (from root) |
| `pnpm rubocop` | Run RuboCop linting |
| `pnpm rubocop:autocorrect` | Auto-correct RuboCop offenses |
| `pnpm test` | Run RSpec tests |
| `pnpm generate:openapi` | Regenerate OpenAPI spec from RSwag specs |
| `pnpm validate:openapi` | Validate OpenAPI spec |

## 📁 Key Directories

```
backend/
├── app/
│   ├── controllers/api/v1/       # API endpoints (inherit from BaseController)
│   ├── controllers/concerns/api/v1/ # JsonapiActions, PagySupport, etc.
│   ├── models/                   # ActiveRecord models
│   ├── resources/                # Graphiti resource definitions
│   └── services/                 # Orchestrators and service objects
├── spec/
│   ├── requests/api/v1/          # RSwag contract specs
│   ├── resources/                # Graphiti resource specs
│   └── swagger_helper.rb         # OpenAPI schema definitions
├── public/api-docs/v1/           # Generated OpenAPI spec
└── lib/tasks/                    # Rake tasks for OpenAPI generation/validation
```

## 📄 License

This project is for interview/development purposes only.
