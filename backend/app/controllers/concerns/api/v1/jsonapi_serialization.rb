# frozen_string_literal: true

# Provides JSON:API serialization methods for single records and collections
# Uses Graphiti resources for attribute introspection during serialization
module Api
  module V1
    module JsonapiSerialization
      extend ActiveSupport::Concern

      private

      def serialize_collection(records)
        resource_class.new
        type = resource_class.type

        data = if records.respond_to?(:to_a)
                 records.to_a.map { |record| serialize_single_record(record, type) }
               else
                 [serialize_single_record(records, type)]
               end

        response = { data: data }

        # Add pagination meta if available
        response[:meta] = pagy_metadata(@pagy) if defined?(@pagy) && @pagy

        response
      end

      def serialize_record(record)
        resource_class.new
        type = resource_class.type

        {
          data: serialize_single_record(record, type)
        }
      end

      def serialize_single_record(record, type)
        attrs = {}

        # Cache resource instance to avoid repeated instantiation
        @resource_instance ||= resource_class.new

        # Graphiti resources have attributes as an array of [attribute_name, options]
        resource_class.attributes.each_key do |name|
          attr_name = name.to_sym
          attrs[attr_name] = record.send(attr_name) if record.respond_to?(attr_name)
        end

        {
          id: record.id,
          type: type,
          attributes: attrs
        }
      end
    end
  end
end
