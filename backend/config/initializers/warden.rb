# frozen_string_literal: true

# Warden configuration for authentication middleware
# NOTE: This is a placeholder implementation. Currently, all requests are authenticated
# as a nil user to maintain backward compatibility. When real authentication is added,
# this should be updated to validate tokens or credentials.

Warden::Manager.serialize_into_session do |user|
  user&.id
end

Warden::Manager.serialize_from_session do |_id|
  # Placeholder: When authentication is implemented, this should find the user by ID
  nil
end

Warden::Strategies.add(:token_strategy) do
  def valid?
    # Placeholder: Always valid for now
    # When authentication is implemented, check for token in headers
    true
  end

  def authenticate!
    # Placeholder: Always fail authentication with nil user for backward compatibility
    # When authentication is implemented, validate the token and set the user
    fail!('Authentication not implemented')
  end
end

Rails.application.config.middleware.use Warden::Manager do |manager|
  manager.default_strategies :token_strategy
  manager.failure_app = lambda do |_env|
    [401, { 'Content-Type' => 'application/json' }, [{ error: 'Unauthorized' }.to_json]]
  end
end
