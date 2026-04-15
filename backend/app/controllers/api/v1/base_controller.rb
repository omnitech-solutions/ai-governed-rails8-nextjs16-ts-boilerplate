# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      include JsonapiActions
      include JsonapiSerialization
      include JsonapiErrorHandling
      include PagySupport
      include Authentication
      include Pundit::Authorization

      class << self
        attr_writer :resource_class, :model_class

        def resource_class
          @resource_class || raise("#{name} must specify resource_class")
        end

        def model_class
          @model_class || raise("#{name} must specify model_class")
        end
      end

      def index
        return unless self.class.jsonapi_actions_enabled.include?(:index)

        records = resource_scope
        render json: serialize_collection(records), status: :ok
      end

      def show
        return unless self.class.jsonapi_actions_enabled.include?(:show)

        record = model_class.find(permitted_params[:id])
        render json: serialize_record(record), status: :ok
      end

      def create
        return unless self.class.jsonapi_actions_enabled.include?(:create)

        record = model_class.new(resource_params)
        if record.save
          render json: serialize_record(record), status: :created
        else
          render json: { errors: format_validation_errors(record) },
                 status: :unprocessable_entity
        end
      end

      def update
        return unless self.class.jsonapi_actions_enabled.include?(:update)

        record = model_class.find(permitted_params[:id])
        if record.update(resource_params)
          render json: serialize_record(record), status: :ok
        else
          render json: { errors: format_validation_errors(record) },
                 status: :unprocessable_entity
        end
      end

      def destroy
        return unless self.class.jsonapi_actions_enabled.include?(:destroy)

        record = model_class.find(permitted_params[:id])
        record.destroy
        head :no_content
      end

      private

      def resource_class
        self.class.resource_class
      end

      def model_class
        self.class.model_class
      end

      def permitted_params
        params.permit(:format, :controller, :action, :id)
      end

      def resource_params
        # Use writable attributes if available, fallback to all attributes for safety
        attribute_names = if resource_class.respond_to?(:writable_attributes)
                            resource_class.writable_attributes.keys
                          else
                            resource_class.new.attributes.map { |attr| attr[0].to_sym }
                          end

        # Extract attributes from JSON:API format or plain params
        params_data = if params[:data] && params[:data][:attributes]
                        params[:data][:attributes]
                      elsif params[:data]
                        params[:data]
                      else
                        params
                      end

        # Ensure params_data is ActionController::Parameters and permit attributes
        unless params_data.is_a?(ActionController::Parameters)
          params_data = ActionController::Parameters.new(params_data.to_unsafe_h)
        end
        params_data.permit(*attribute_names)
      end

      def resource_scope
        @pagy, records = pagy(model_class.all, page: params[:page], items: params[:per_page])
        records
      end

      def format_validation_errors(record)
        record.errors.map do |error|
          {
            title: 'Validation Error',
            detail: error.message,
            status: 422,
            source: {
              pointer: "/data/attributes/#{error.attribute}"
            }
          }
        end
      end
    end
  end
end
