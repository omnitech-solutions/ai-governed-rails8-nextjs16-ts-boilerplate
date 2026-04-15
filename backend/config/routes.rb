Rails.application.routes.draw do
  mount Rswag::Api::Engine => "/api-docs"

  # Serve OpenAPI spec at /api/v1/openapi.json
  get "/api/v1/openapi.json", to: redirect("/api-docs/v1/openapi.json")

  # Mount Rswag UI for Swagger documentation
  mount Rswag::Ui::Engine => "/api-docs"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Redirect root to frontend
  root to: redirect(->(_params, request) { "#{request.protocol}#{request.host}:3001" })
end
