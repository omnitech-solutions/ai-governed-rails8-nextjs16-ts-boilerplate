# frozen_string_literal: true

# Provides nested resource functionality for controllers
# Handles parent resource loading and scoping through associations
module Api
  module V1
    module NestedResource
      extend ActiveSupport::Concern

      included do
        class << self
          attr_accessor :parent_model_class, :association_name
        end

        before_action :set_parent, if: :parent_model_class
      end

      private

      def parent_model_class
        self.class.parent_model_class
      end

      def set_parent
        parent_param = params["#{parent_model_class.name.downcase}_id"]
        @parent = parent_model_class.find(parent_param)
      rescue ActiveRecord::RecordNotFound
        render json: {
          errors: [{
            title: 'Not Found',
            detail: "#{parent_model_class.name} not found",
            status: 404
          }]
        }, status: :not_found
      end

      def parent
        @parent
      end

      def resource_scope
        if parent
          # For nested resources, use the configured association_name
          assoc_name = self.class.association_name || model_class.name.downcase.pluralize
          # Apply pagination to nested collections
          @pagy, records = pagy(parent.public_send(assoc_name), page: params[:page], items: params[:per_page])
          records
        else
          # For non-nested resources, use model_class.all
          model_class.all
        end
      end
    end
  end
end
