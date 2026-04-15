# frozen_string_literal: true

namespace :openapi do
  desc 'Generate OpenAPI 3.0 spec from Graphiti resources'
  task generate: :environment do
    api_base_url = ENV.fetch('API_BASE_URL', 'http://localhost:3000')

    # Cache for controller introspection results to avoid repeated file reads
    @response_style_cache = {}

    # Type mapping from Graphiti to OpenAPI
    TYPE_MAPPING = {
      integer: { type: 'integer' },
      integer_id: { type: 'integer' },
      string: { type: 'string' },
      date: { type: 'string', format: 'date' },
      datetime: { type: 'string', format: 'date-time' },
      boolean: { type: 'boolean' },
      float: { type: 'number', format: 'float' },
      decimal: { type: 'number', format: 'double' },
      hash: { type: 'object' },
      array: { type: 'array', items: { type: 'object' } },
      uuid: { type: 'string', format: 'uuid' }
    }.freeze

    # Discover all Graphiti resources
    resources = discover_resources

    # Build OpenAPI spec
    spec = {
      'openapi' => '3.0.0',
      'info' => {
        'title' => 'Boilerplate API',
        'version' => '1.0.0',
        'description' => 'API for managing companies, users, projects, and tasks'
      },
      'servers' => [
        { 'url' => api_base_url, 'description' => 'Development server' },
        { 'url' => 'https://api.example.com', 'description' => 'Production server (placeholder)' }
      ],
      'paths' => {},
      'components' => {
        'schemas' => {}
      }
    }

    # Process each resource
    resources.each do |resource_class|
      resource_type = resource_class.type.to_s
      resource_name = resource_type.singularize.capitalize

      # Extract attributes using Graphiti's public API
      attributes = extract_attributes(resource_class)

      # Extract filters for documentation
      filters = extract_filters(resource_class)

      # Extract relationships (sideloads) for documentation
      relationships = extract_relationships(resource_class)

      # Determine required fields from model validations or config override
      required_fields = determine_required_fields(resource_class, attributes, resource_type)

      # Generate schema for this resource
      spec['components']['schemas'][resource_name] = generate_schema(attributes, TYPE_MAPPING)

      # Add filter and relationship documentation to the schema description
      if filters.any? || relationships.any?
        description = []
        description << "**Filters:** #{filters.keys.join(', ')}" if filters.any?
        description << "**Relationships:** #{relationships.keys.join(', ')}" if relationships.any?
        spec['components']['schemas'][resource_name]['description'] = description.join('\n') if description.any?
      end

      # Generate paths
      base_path = "/api/v1/#{resource_type}"
      # Dynamically determine response styles from controller introspection
      index_style = determine_index_response_style(resource_class)
      create_style = determine_create_response_style(resource_class)
      spec['paths'][base_path] =
        generate_index_path(resource_type, resource_name, attributes, TYPE_MAPPING, index_style, create_style, required_fields,
                            filters)
      spec['paths']["#{base_path}/{id}"] =
        generate_member_path(resource_type, resource_name, attributes, TYPE_MAPPING, create_style, required_fields)
    end

    # Write to file
    output_path = Rails.root.join('public/api-docs/v1/openapi.json')
    FileUtils.mkdir_p(output_path.dirname)
    File.write(output_path, JSON.pretty_generate(spec))

    puts "OpenAPI spec generated at #{output_path}"
  end

  desc 'Validate OpenAPI spec'
  task validate: :environment do
    spec_path = Rails.root.join('public/api-docs/v1/openapi.json')

    unless File.exist?(spec_path)
      puts "OpenAPI spec not found at #{spec_path}"
      exit 1
    end

    begin
      schema = JSON.parse(File.read(spec_path))
      # Basic validation - check if it's valid JSON and has required fields
      required_fields = %w[openapi info paths]
      missing_fields = required_fields - schema.keys

      if missing_fields.any?
        puts "Invalid OpenAPI spec: missing required fields: #{missing_fields.join(', ')}"
        exit 1
      end

      # Check openapi version
      unless ['3.0.0', '3.0.1', '3.0.2', '3.0.3', '3.1.0'].include?(schema['openapi'])
        puts "Invalid OpenAPI spec: unsupported openapi version: #{schema['openapi']}"
        exit 1
      end

      puts 'OpenAPI spec is valid'
    rescue JSON::ParserError => e
      puts "Invalid JSON in OpenAPI spec: #{e.message}"
      exit 1
    end
  end

  private

  def discover_resources
    # Load all resource files safely without duplicate requires
    resource_files = Dir[Rails.root.join('app/resources/*_resource.rb')]
    resource_files.each do |file|
      basename = File.basename(file, '.rb')
      next if ObjectSpace.each_object(Class).any? { |klass| klass.name == basename.camelize }

      require file
    end

    # Get all resource classes
    ObjectSpace.each_object(Class).select do |klass|
      klass < ApplicationResource && klass != ApplicationResource
    end
  end

  # Extract attributes using Graphiti's public API
  # resource_class.attributes returns a hash of attribute names to their configuration
  def extract_attributes(resource_class)
    attributes = {}

    # Use Graphiti's public attributes method
    if resource_class.respond_to?(:attributes)
      resource_class.attributes.each do |name, config|
        type = config[:type] || :string
        attributes[name.to_s] = type
      end
    end

    # Ensure id is always included if not present
    attributes['id'] = :integer unless attributes.key?('id')

    # Ensure timestamps are included if not already
    attributes['created_at'] = :datetime unless attributes.key?('created_at')
    attributes['updated_at'] = :datetime unless attributes.key?('updated_at')

    attributes
  end

  # Extract filters using Graphiti's public API
  # resource_class.filters returns a hash of filter names to their configuration
  def extract_filters(resource_class)
    filters = {}

    if resource_class.respond_to?(:filters)
      resource_class.filters.each do |name, config|
        filters[name.to_s] = {
          type: config[:type],
          operators: config[:operators].keys.reject { |k| config[:operators][k].nil? }
        }
      end
    end

    filters
  end

  # Extract relationships using Graphiti's public API
  # resource_class.sideloads returns a hash of relationship names to their configuration
  def extract_relationships(resource_class)
    relationships = {}

    if resource_class.respond_to?(:sideloads)
      resource_class.sideloads.each do |name, sideload|
        relationships[name.to_s] = {
          type: sideload.type,
          resource_class: sideload.resource_class&.name
        }
      end
    end

    relationships
  end

  # Determine required fields by checking model validations
  # Falls back to checking the ActiveRecord model for presence validations
  def determine_required_fields(resource_class, attributes, _resource_type)
    # Try to infer from model validations
    required = []

    if resource_class.respond_to?(:model) && resource_class.model
      model = resource_class.model
      if model.respond_to?(:validators_on)
        attributes.each_key do |attr_name|
          next if attr_name == 'id' || attr_name =~ /_at$/

          # Check if the model has a presence validator for this attribute
          validators = model.validators_on(attr_name.to_sym)
          has_presence = validators.any? { |v| v.kind == :presence }
          required << attr_name if has_presence
        end
      end
    end

    required
  end

  # Find the controller class for a given Graphiti resource
  # Returns nil if controller is not found
  def controller_for(resource_class)
    resource_type = resource_class.type.to_s # "companies"
    controller_name = "Api::V1::#{resource_type.camelize}Controller"
    controller_name.constantize
  rescue NameError
    nil
  end

  # Determine index response style by inspecting the controller's index action
  # Returns :array or :wrapped
  def determine_index_response_style(resource_class)
    # Check cache first
    cache_key = resource_class.name
    return @response_style_cache[cache_key][:index] if @response_style_cache[cache_key]&.[](:index)

    controller = controller_for(resource_class)
    return :array unless controller

    # Verify the index action exists
    return :array unless controller.action_methods.include?('index')

    # Get the source code of the index method
    begin
      source = controller.instance_method(:index).source

      # Parse the source to detect the render format
      # Normalize whitespace to handle multiline render statements
      normalized_source = source.gsub(/\s+/, ' ')

      # Pattern for wrapped: render json: { data: ..., meta: ... }
      # Check if render json contains both 'data:' and 'meta:' keys
      style = if normalized_source.include?('render json:') &&
                 normalized_source.include?('data:') &&
                 normalized_source.include?('meta:')
                :wrapped
              # Pattern for array: render json: @companies or render json: @records
              elsif normalized_source =~ /render\s+json:\s*@\w+/
                :array
              else
                # Default to array if pattern not recognized
                :array
              end
    rescue StandardError => e
      # If introspection fails, default to :array
      Rails.logger.debug "Could not introspect index action for #{resource_class.name}: #{e.message}"
      style = :array
    end

    # Cache the result
    @response_style_cache[cache_key] ||= {}
    @response_style_cache[cache_key][:index] = style
    style
  end

  # Determine create/update response style by inspecting the controller's create action
  # Returns :object or :wrapped
  def determine_create_response_style(resource_class)
    # Check cache first
    cache_key = resource_class.name
    return @response_style_cache[cache_key][:create] if @response_style_cache[cache_key]&.[](:create)

    controller = controller_for(resource_class)
    return :object unless controller

    # Check create action first, fall back to update if create doesn't exist
    action_name = controller.action_methods.include?('create') ? 'create' : 'update'
    return :object unless controller.action_methods.include?(action_name)

    # Get the source code of the action method
    begin
      source = controller.instance_method(action_name.to_sym).source

      # Normalize whitespace to handle multiline render statements
      normalized_source = source.gsub(/\s+/, ' ')

      # Parse the source to detect the render format
      # Pattern for wrapped: render json: { success: true, data: ... }
      # Check if render json contains both 'success:' and 'data:' keys
      style = if normalized_source.include?('render json:') &&
                 normalized_source.include?('success:') &&
                 normalized_source.include?('data:')
                :wrapped
              # Pattern for object: render json: @company
              elsif normalized_source =~ /render\s+json:\s*@\w+/
                :object
              else
                # Default to object if pattern not recognized
                :object
              end
    rescue StandardError => e
      # If introspection fails, default to :object
      Rails.logger.debug "Could not introspect #{action_name} action for #{resource_class.name}: #{e.message}"
      style = :object
    end

    # Cache the result
    @response_style_cache[cache_key] ||= {}
    @response_style_cache[cache_key][:create] = style
    style
  end

  def generate_schema(attributes, type_mapping)
    properties = {}

    attributes.each do |name, type|
      properties[name] = type_mapping[type] || type_mapping[:string]
    end

    {
      'type' => 'object',
      'properties' => properties
    }
  end

  def generate_index_path(resource_type, resource_name, attributes, type_mapping, index_style, create_style,
                          required_fields, filters)
    style = index_style
    schema_ref = { '$ref' => "#/components/schemas/#{resource_name}" }

    path = {
      'get' => {
        'operationId' => "list#{resource_name.pluralize}",
        'tags' => [resource_name.pluralize],
        'summary' => "List all #{resource_type}",
        'responses' => {
          '200' => {
            'description' => "#{resource_type} found",
            'content' => {
              'application/json' => {
                'schema' => build_index_response_schema(style, schema_ref)
              }
            }
          }
        }
      },
      'post' => {
        'operationId' => "create#{resource_name}",
        'tags' => [resource_name.pluralize],
        'summary' => "Create a #{resource_type.singularize}",
        'requestBody' => {
          'required' => true,
          'content' => {
            'application/json' => {
              'schema' => build_request_schema(attributes, type_mapping, resource_type, required_fields)
            }
          }
        },
        'responses' => {
          '201' => {
            'description' => "#{resource_type.singularize} created",
            'content' => {
              'application/json' => {
                'schema' => build_create_response_schema(create_style, schema_ref)
              }
            }
          }
        }
      }
    }

    # Add pagination parameters for wrapped responses
    if style == :wrapped
      path['get']['parameters'] = [
        { 'name' => 'page', 'in' => 'query', 'schema' => { 'type' => 'integer' } },
        { 'name' => 'per_page', 'in' => 'query', 'schema' => { 'type' => 'integer' } }
      ]
    end

    # Add filter parameters for documentation
    if filters.any?
      path['get']['parameters'] ||= []
      filters.each do |filter_name, filter_config|
        param = {
          'name' => filter_name,
          'in' => 'query',
          'schema' => type_mapping[filter_config[:type]] || { 'type' => 'string' },
          'description' => "Filter by #{filter_name}"
        }
        path['get']['parameters'] << param
      end
    end

    path
  end

  def generate_member_path(resource_type, resource_name, attributes, type_mapping, create_style, required_fields)
    schema_ref = { '$ref' => "#/components/schemas/#{resource_name}" }

    {
      'get' => {
        'operationId' => "show#{resource_name}",
        'tags' => [resource_name.pluralize],
        'summary' => "Show a #{resource_type.singularize}",
        'parameters' => [
          { 'name' => 'id', 'in' => 'path', 'required' => true, 'schema' => { 'type' => 'integer' } }
        ],
        'responses' => {
          '200' => {
            'description' => "#{resource_type.singularize} found",
            'content' => {
              'application/json' => {
                'schema' => schema_ref
              }
            }
          }
        }
      },
      'patch' => {
        'operationId' => "update#{resource_name}",
        'tags' => [resource_name.pluralize],
        'summary' => "Update a #{resource_type.singularize}",
        'parameters' => [
          { 'name' => 'id', 'in' => 'path', 'required' => true, 'schema' => { 'type' => 'integer' } }
        ],
        'requestBody' => {
          'required' => true,
          'content' => {
            'application/json' => {
              'schema' => build_request_schema(attributes, type_mapping, resource_type, required_fields, optional: true)
            }
          }
        },
        'responses' => {
          '200' => {
            'description' => "#{resource_type.singularize} updated",
            'content' => {
              'application/json' => {
                'schema' => build_create_response_schema(create_style, schema_ref)
              }
            }
          }
        }
      },
      'delete' => {
        'operationId' => "delete#{resource_name}",
        'tags' => [resource_name.pluralize],
        'summary' => "Delete a #{resource_type.singularize}",
        'parameters' => [
          { 'name' => 'id', 'in' => 'path', 'required' => true, 'schema' => { 'type' => 'integer' } }
        ],
        'responses' => {
          '204' => {
            'description' => "#{resource_type.singularize} deleted"
          }
        }
      }
    }
  end

  def build_index_response_schema(style, schema_ref)
    case style
    when :array
      {
        'type' => 'array',
        'items' => schema_ref
      }
    when :wrapped
      {
        'type' => 'object',
        'properties' => {
          'data' => {
            'type' => 'array',
            'items' => schema_ref
          },
          'meta' => {
            'type' => 'object',
            'properties' => {
              'page' => { 'type' => 'integer' },
              'per_page' => { 'type' => 'integer' },
              'total' => { 'type' => 'integer' }
            }
          }
        }
      }
    else
      { 'type' => 'array', 'items' => schema_ref }
    end
  end

  def build_create_response_schema(style, schema_ref)
    case style
    when :wrapped
      {
        'type' => 'object',
        'properties' => {
          'success' => { 'type' => 'boolean' },
          'data' => schema_ref
        }
      }
    else
      schema_ref
    end
  end

  def build_request_schema(attributes, type_mapping, _resource_type, required_fields, optional: false)
    properties = {}
    required = []

    # required_fields is now an array of field names for this resource
    resource_required = required_fields.is_a?(Array) ? required_fields : []

    attributes.each do |name, type|
      # Skip id and timestamps in request bodies
      next if %w[id created_at updated_at].include?(name)

      properties[name] = type_mapping[type] || type_mapping[:string]

      # Mark as required if it's in the resource's required fields array and not optional
      required << name if resource_required.include?(name) && !optional
    end

    schema = {
      'type' => 'object',
      'properties' => properties
    }

    schema['required'] = required if required.any?

    schema
  end
end
