# frozen_string_literal: true

# Provides opt-in JSON:API CRUD actions for controllers
# Controllers can specify which actions to enable using the jsonapi_actions class method
module Api
  module V1
    module JsonapiActions
      extend ActiveSupport::Concern

      included do
        class << self
          attr_accessor :jsonapi_actions_enabled
        end
      end

      class_methods do
        def jsonapi_actions(*actions)
          self.jsonapi_actions_enabled = if actions.include?(:all)
                                           %i[index show create update destroy]
                                         else
                                           actions
                                         end
        end
      end
    end
  end
end
