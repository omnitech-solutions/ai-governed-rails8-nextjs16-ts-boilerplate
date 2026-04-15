# frozen_string_literal: true

Rails.application.configure do
  # Lograge configuration
  config.lograge.enabled = true

  # Use key-value format for structured logging
  config.lograge.formatter = Lograge::Formatters::KeyValue.new

  # Disable the default Rails log
  config.lograge.keep_original_rails_log = false

  # Customize the log format
  config.lograge.custom_options = lambda do |event|
    {
      params: event.payload[:params].except("controller", "action"),
      user_id: event.payload[:user_id],
      request_id: event.payload[:request_id]
    }.compact
  end

  # Log all controller actions
  config.lograge.ignore_actions = []
end
