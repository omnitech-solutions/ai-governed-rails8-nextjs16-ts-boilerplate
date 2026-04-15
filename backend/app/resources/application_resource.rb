# frozen_string_literal: true

class ApplicationResource < Graphiti::Resource
  self.endpoint_namespace = '/api/v1'
  self.adapter = Graphiti::Adapters::ActiveRecord

  # CRITICAL: Override default resource type naming
  def self.type
    # Remove '_resources' suffix for cleaner URLs
    name.demodulize.gsub('Resource', '').underscore.pluralize
  end

  # Default pagination
  self.default_page_size = 20
  self.max_page_size = 100
end
