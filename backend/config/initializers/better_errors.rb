# frozen_string_literal: true

# Better Errors configuration for development
BetterErrors.editor = :sublime_text if Rails.env.development? && defined?(BetterErrors)
