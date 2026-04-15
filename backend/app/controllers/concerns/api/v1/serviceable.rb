# frozen_string_literal: true

# Serviceable concern for integrating service layer into controllers.
# Provides a DSL to configure an orchestrator and automatically routes
# create, update, and destroy actions through the service layer.
module Api
  module V1
    module Serviceable
      extend ActiveSupport::Concern

      included do
        class_attribute :service_orchestrator_class
      end

      class_methods do
        # Set the orchestrator for this controller
        # @param orchestrator_class [Class] the orchestrator class to use
        def service_orchestrator(orchestrator_class)
          self.service_orchestrator_class = orchestrator_class
          # Automatically set jsonapi_actions to :index, :show only if not already configured
          # This reduces boilerplate in controllers while allowing explicit configuration
          jsonapi_actions(:index, :show) if jsonapi_actions_enabled.nil?
        end
      end

      # Execute the service orchestrator for the given action
      # @param action [Symbol] the action to execute (:create, :update, or :destroy)
      # @param resource [ApplicationRecord] the resource to operate on
      # @param params [Hash] the parameters for the action
      # @return [Hash] the result context from the orchestrator
      def execute_service(action, resource, params)
        return unless service_orchestrator_class

        service_orchestrator_class.call(
          resource: resource,
          params: params,
          action: action
        )
      end

      # Override the default create action to use the service layer
      def create
        if service_orchestrator_class
          resource = model_class.new(resource_params)
          result = execute_service(:create, resource, resource_params) || {}

          if result[:success]
            render json: serialize_record(result[:resource]), status: :created
          else
            render json: { errors: result[:errors] }, status: :unprocessable_entity
          end
        else
          super
        end
      end

      # Override the default update action to use the service layer
      def update
        if service_orchestrator_class
          resource = model_class.find(permitted_params[:id])
          result = execute_service(:update, resource, resource_params) || {}

          if result[:success]
            render json: serialize_record(result[:resource]), status: :ok
          else
            render json: { errors: result[:errors] }, status: :unprocessable_entity
          end
        else
          super
        end
      end

      # Override the default destroy action to use the service layer
      def destroy
        if service_orchestrator_class
          resource = model_class.find(permitted_params[:id])
          result = execute_service(:destroy, resource, {}) || {}

          if result[:success]
            head :no_content
          else
            render json: { errors: result[:errors] }, status: :unprocessable_entity
          end
        else
          super
        end
      end
    end
  end
end
