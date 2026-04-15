# frozen_string_literal: true

# Provides Pagy integration for controllers
# Includes Pagy::Backend and provides helper methods for pagination metadata
module Api
  module V1
    module PagySupport
      extend ActiveSupport::Concern

      included do
        include Pagy::Backend
      end

      private

      # Returns pagination metadata in JSON:API format
      def pagy_metadata(pagy)
        {
          page: pagy.page,
          per_page: pagy.items,
          total: pagy.count,
          total_pages: pagy.pages
        }
      end
    end
  end
end
