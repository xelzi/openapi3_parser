# frozen_string_literal: true

require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactory
    class Response < NodeFactory::Object
      allow_extensions
      field "description", input_type: String, required: true
      field "headers", factory: :headers_factory
      field "content", factory: :content_factory
      field "links", factory: :links_factory

      private

      def build_object(data, context)
        Node::Response.new(data, context)
      end

      def headers_factory(input, context)
        factory = NodeFactory::OptionalReference.new(NodeFactory::Header)
        NodeFactory::Map.new(input, context, value_factory: factory)
      end

      def content_factory(input, context)
        NodeFactory::Map.new(input,
                             context,
                             validate: method(:validate_content),
                             value_factory: NodeFactory::MediaType)
      end

      def links_factory(input, context)
        factory = NodeFactory::OptionalReference.new(NodeFactory::Link)
        NodeFactory::Map.new(
          input,
          context,
          validate: Validation::InputValidator.new(Validators::ComponentKeys),
          value_factory: factory
        )
      end

      def validate_content(validatable)
        validatable.input.each_key do |key|
          message = Validators::MediaType.call(key)
          next unless message
          validatable.add_error(message,
                                Context.next_field(validatable.context, key))
        end
      end
    end
  end
end
