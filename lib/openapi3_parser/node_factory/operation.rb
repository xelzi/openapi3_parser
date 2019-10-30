# frozen_string_literal: true

require "openapi3_parser/node_factory/object"
require "openapi3_parser/node_factory/external_documentation"
require "openapi3_parser/node_factory/responses"

module Openapi3Parser
  module NodeFactory
    class Operation < NodeFactory::Object
      allow_extensions
      field "tags", factory: :tags_factory
      field "summary", input_type: String
      field "description", input_type: String
      field "externalDocs", factory: NodeFactory::ExternalDocumentation
      field "operationId", input_type: String
      field "parameters", factory: :parameters_factory
      field "requestBody", factory: :request_body_factory
      field "responses", factory: NodeFactory::Responses,
                         required: true
      field "callbacks", factory: :callbacks_factory
      field "deprecated", input_type: :boolean, default: false
      field "security", factory: :security_factory
      field "servers", factory: :servers_factory

      private

      def build_object(data, context)
        Node::Operation.new(data, context)
      end

      def tags_factory(input, context)
        NodeFactory::Array.new(input, context, value_input_type: String)
      end

      def parameters_factory(input, context)
        factory = NodeFactory::OptionalReference.new(NodeFactory::Parameter)

        validate_parameters = lambda do |validatable|
          validatable.add_error(
            Validators::DuplicateParameters.call(
              validatable.factory.resolved_input
            )
          )
        end

        NodeFactory::Array.new(input,
                               context,
                               value_factory: factory,
                               validate: validate_parameters)
      end

      def request_body_factory(input, context)
        factory = NodeFactory::RequestBody
        NodeFactory::OptionalReference.new(factory).call(input, context)
      end

      def callbacks_factory(input, context)
        factory = NodeFactory::OptionalReference.new(NodeFactory::Callback)
        NodeFactory::Map.new(input, context, value_factory: factory)
      end

      def responses_factory(input, context)
        factory = NodeFactory::RequestBody
        NodeFactory::OptionalReference.new(factory).call(input, context)
      end

      def security_factory(input, context)
        NodeFactory::Array.new(input,
                               context,
                               value_factory: NodeFactory::SecurityRequirement)
      end

      def servers_factory(input, context)
        NodeFactory::Array.new(input,
                               context,
                               value_factory: NodeFactory::Server)
      end
    end
  end
end
