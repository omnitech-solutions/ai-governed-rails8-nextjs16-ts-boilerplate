# frozen_string_literal: true

# Provides JSON:API compliant error handling for common exceptions
# Rescues RecordNotFound, RecordInvalid, and ValidationError
module Api
  module V1
    module JsonapiErrorHandling
      extend ActiveSupport::Concern

      included do
        rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
        rescue_from Graphiti::Errors::RecordNotFound, with: :record_not_found
        rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
        rescue_from Graphiti::Errors::ValidationError, with: :validation_error
      end

      private

      def record_not_found(error)
        render json: {
          errors: [{
            title: 'Not Found',
            detail: error.message,
            status: 404
          }]
        }, status: :not_found
      end

      def record_invalid(error)
        render json: {
          errors: error.record.errors.map do |attribute, message|
            {
              title: 'Validation Error',
              detail: message,
              status: 422,
              source: {
                pointer: "/data/attributes/#{attribute}"
              }
            }
          end
        }, status: :unprocessable_entity
      end

      def validation_error(error)
        render json: {
          errors: [{
            title: 'Validation Error',
            detail: error.message,
            status: 422
          }]
        }, status: :unprocessable_entity
      end
    end
  end
end
