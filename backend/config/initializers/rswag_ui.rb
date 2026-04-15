# frozen_string_literal: true

Rswag::Ui.configure do |c|
  c.openapi_endpoint '/api/v1/openapi.json', 'API V1 Documentation'

  c.config_object[:deepLinking] = true
  c.config_object[:persistAuthorization] = true
  c.config_object[:displayOperationId] = true
  c.config_object[:tryItOutEnabled] = true
end
