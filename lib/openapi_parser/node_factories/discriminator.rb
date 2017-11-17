# frozen_string_literal: true

require "openapi_parser/nodes/discriminator"
require "openapi_parser/node_factory/object"

module OpenapiParser
  module NodeFactories
    class Discriminator
      include NodeFactory::Object

      field "propertyName", input_type: String, required: true
      field "mapping", input_type: Hash,
                       validate: :validate_mapping,
                       default: -> { {}.freeze }

      private

      def build_object(data, context)
        Nodes::Discriminator.new(data, context)
      end

      def validate_mapping(input)
        return if input.empty?
        string_keys = input.keys.map(&:class).uniq == [String]
        string_values = input.values.map(&:class).uniq == [String]
        valid = string_keys && string_values
        return "Expected string keys and string values" unless valid
      end
    end
  end
end
