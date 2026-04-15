# frozen_string_literal: true

namespace :openapi do
  desc 'Validate the manual OpenAPI spec file (v1/openapi.json)'
  task validate: :environment do
    spec_path = Rails.root.join('public', 'api-docs', 'v1', 'openapi.json')

    unless spec_path.exist?
      puts "❌ Error: OpenAPI spec file not found at #{spec_path}"
      exit 1
    end

    begin
      spec_content = spec_path.read
      spec_json = JSON.parse(spec_content)
    rescue JSON::ParserError => e
      puts "❌ Error: Invalid JSON in #{spec_path}"
      puts "  #{e.message}"
      exit 1
    end

    required_keys = %w[openapi info paths]
    missing_keys = required_keys - spec_json.keys

    unless missing_keys.empty?
      puts "❌ Error: Missing required top-level keys: #{missing_keys.join(', ')}"
      exit 1
    end

    # Validate openapi version format
    unless spec_json['openapi'].is_a?(String) && spec_json['openapi'].match?(/\d+\.\d+\.\d+/)
      puts '❌ Error: Invalid or missing openapi version (expected format: x.y.z)'
      exit 1
    end

    # Validate info object
    unless spec_json['info'].is_a?(Hash)
      puts "❌ Error: 'info' must be an object"
      exit 1
    end

    info_required_keys = %w[title version]
    info_missing_keys = info_required_keys - spec_json['info'].keys

    unless info_missing_keys.empty?
      puts "❌ Error: Missing required keys in 'info': #{info_missing_keys.join(', ')}"
      exit 1
    end

    # Validate paths object
    unless spec_json['paths'].is_a?(Hash)
      puts "❌ Error: 'paths' must be an object"
      exit 1
    end

    puts "⚠️  Warning: 'paths' object is empty (no API endpoints documented)" if spec_json['paths'].empty?

    # Validate that all paths start with /api/v1
    invalid_paths = spec_json['paths'].keys.reject { |path| path.start_with?('/api/v1/') }
    puts "⚠️  Warning: Some paths do not start with /api/v1/: #{invalid_paths.join(', ')}" unless invalid_paths.empty?

    # Validate that all operations have operationId
    operations_without_id = []
    spec_json['paths'].each do |path, path_data|
      path_data.each do |method, operation_data|
        next unless operation_data.is_a?(Hash)

        operations_without_id << "#{method.upcase} #{path}" unless operation_data['operationId']
      end
    end

    unless operations_without_id.empty?
      puts "⚠️  Warning: Some operations are missing operationId (recommended for Swagger UI): #{operations_without_id.join(', ')}"
    end

    puts '✅ OpenAPI spec validation passed'
    puts "   File: #{spec_path}"
    puts "   OpenAPI Version: #{spec_json['openapi']}"
    puts "   API Title: #{spec_json['info']['title']}"
    puts "   API Version: #{spec_json['info']['version']}"
    puts "   Endpoints documented: #{spec_json['paths'].keys.count}"
  end
end
