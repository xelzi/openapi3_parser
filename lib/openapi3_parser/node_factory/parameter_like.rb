# frozen_string_literal: true

module Openapi3Parser
  module NodeFactory
    module ParameterLike
      def default_explode
        context.input["style"] == "form"
      end

      def schema_factory(input, context)
        factory = NodeFactory::OptionalReference.new(NodeFactory::Schema)
        factory.call(input, context)
      end

      def examples_factory(input, context)
        factory = NodeFactory::OptionalReference.new(NodeFactory::Schema)
        NodeFactory::Map.new(input,
                             context,
                             default: nil,
                             value_factory: factory)
      end

      def content_factory(input, context)
        NodeFactory::Map.new(input,
                             context,
                             default: nil,
                             value_factory: NodeFactory::MediaType,
                             validate: method(:validate_content))
      end

      def validate_content(validatable)
        return if validatable.input.size == 1
        validatable.add_error("Must only have one item")
      end
    end
  end
end
