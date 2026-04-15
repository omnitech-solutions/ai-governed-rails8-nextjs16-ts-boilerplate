# frozen_string_literal: true

# Core orchestrator abstraction inspired by Flowlight.
# Wraps a resource and executes a chain of actions defined as methods within the class.
# Provides a consistent context object with success, errors, and the resource.
class ApplicationOrchestrator
  class << self
    # @param resource [ApplicationRecord] the model instance being operated on
    # @param params [Hash] additional parameters (e.g., from controller)
    # @param action [Symbol] the specific action to execute (e.g., :create, :update, :destroy)
    # @return [Hash] the result context
    def call(resource:, params: {}, action: nil)
      new(resource, params).call(action)
    end
  end

  attr_reader :resource, :params

  def initialize(resource, params = {})
    @resource = resource
    @params = params
  end

  # Execute the specified action or default action
  # @param action_name [Symbol] the action to execute
  # @return [Hash] the result context
  def call(action_name = nil)
    action_name ||= default_action
    context = { resource: resource, params: params, success: true, errors: nil }

    actions = self.class.actions_for(action_name)
    execute_actions(context, actions)
  end

  # DSL method to define an action sequence
  # @param name [Symbol] the action name (e.g., :create, :update, :destroy)
  # @param action_names [Array<Symbol>] the sequence of action methods to execute
  def self.action(name, *action_names)
    action_sequences[name] = action_names
  end

  # Macro to define standard CRUD actions with inline action sequences.
  # Dramatically reduces boilerplate for common CRUD operations.
  #
  # @param create_actions [Array<Symbol>] action sequence for create
  # @param update_actions [Array<Symbol>] action sequence for update
  # @param destroy_actions [Array<Symbol>] action sequence for destroy
  def self.crud_actions(create_actions: nil, update_actions: nil, destroy_actions: nil)
    action(:create, *(create_actions || default_create_actions))
    action(:update, *(update_actions || default_update_actions))
    action(:destroy, *(destroy_actions || default_destroy_actions))
  end

  # Get the action sequence for a given action name
  # @param action_name [Symbol] the action name
  # @return [Array<Symbol>] the sequence of action methods
  def self.actions_for(action_name)
    action_sequences[action_name] || []
  end

  # Store action sequences
  def self.action_sequences
    @action_sequences ||= {}
  end

  # Execute a sequence of actions
  # @param context [Hash] the context object
  # @param action_names [Array<Symbol>] the action methods to execute
  # @return [Hash] the final context
  def execute_actions(context, action_names)
    action_names.reduce(context) do |ctx, action_name|
      break ctx unless ctx[:success]

      send(action_name, ctx)
    end
  end

  # Format errors in JSON:API compatible format
  # @param record [ActiveModel::Validations] the record with errors
  # @return [Array<Hash>] formatted error objects
  def format_errors(record)
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

  # Mark context as successful
  # @param context [Hash] the context object
  # @param additional_attrs [Hash] additional attributes to merge
  # @return [Hash] the updated context
  def success!(context, additional_attrs = {})
    context.merge(success: true).merge(additional_attrs)
  end

  # Mark context as failed
  # @param context [Hash] the context object
  # @param additional_attrs [Hash] additional attributes to merge (e.g., errors)
  # @return [Hash] the updated context
  def fail!(context, additional_attrs = {})
    context.merge(success: false).merge(additional_attrs)
  end

  private

  # Default action to execute if none specified
  # @return [Symbol] the default action name
  def default_action
    :create
  end

  # Default action sequences for CRUD operations
  # Can be overridden in subclasses
  class << self
    private

    def default_create_actions
      %i[validate save]
    end

    def default_update_actions
      %i[validate save]
    end

    def default_destroy_actions
      %i[destroy_record]
    end
  end

  # Validate the resource using Graphiti resource for attribute whitelisting
  def validate(context)
    resource = context[:resource]
    params = context[:params]

    # Use Graphiti resource to whitelist attributes
    resource_klass = "#{resource.class.name}Resource".safe_constantize
    if resource_klass
      # Get writable attributes from the resource
      # Graphiti attributes hash has :writable key
      writable_attrs = resource_klass.attributes.each_with_object([]) do |(name, config), arr|
        arr << name if config.fetch(:writable, true)
      end
      permitted_params = params.slice(*writable_attrs)
      resource.assign_attributes(permitted_params)
    else
      resource.assign_attributes(params)
    end

    # Validate the resource
    if resource.valid?
      success!(context)
    else
      fail!(context, errors: format_errors(resource))
    end
  end

  # Save the resource record
  def save(context)
    resource = context[:resource]

    if resource.save
      success!(context, resource: resource)
    else
      fail!(context, errors: format_errors(resource))
    end
  end

  # Destroy the resource record (soft delete via paranoia)
  def destroy_record(context)
    resource = context[:resource]

    if resource.destroy
      success!(context, resource: resource)
    else
      fail!(context, errors: format_errors(resource))
    end
  end
end
