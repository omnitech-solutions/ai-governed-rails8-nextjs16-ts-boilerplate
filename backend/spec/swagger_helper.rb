# frozen_string_literal: true

# Load Rails environment for swagger_helper
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('public/api-docs').to_s
  config.openapi_specs = {
    'v1/openapi.json' => {
      openapi: '3.0.0',
      info: {
        title: 'Wrapbook API',
        version: 'v1',
        description: 'API for managing companies and users'
      },
      servers: [
        {
          url: ENV.fetch('API_BASE_URL', 'http://localhost:3000'),
          description: 'Development server'
        }
      ],
      paths: {},
      components: {
        schemas: {
          Company: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          },
          User: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              email: { type: :string },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          },
          CompanyRequest: {
            type: :object,
            properties: {
              name: { type: :string }
            },
            required: ['name']
          },
          UserRequest: {
            type: :object,
            properties: {
              name: { type: :string },
              email: { type: :string }
            },
            required: ['name', 'email']
          },
          Error: {
            type: :object,
            properties: {
              errors: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    title: { type: :string },
                    detail: { type: :string },
                    status: { type: :integer }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
end
