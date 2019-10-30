# frozen_string_literal: true

module Openapi3Parser
  module NodeFactory
    class OptionalReference
      def initialize(factory)
        @factory = factory
      end

      def object_type
        "#{self.class}[#{factory.object_type}]}"
      end

      def call(input, context)
        reference = input.is_a?(Hash) && context.input["$ref"]

        if reference
          NodeFactory::Reference.new(input, context, self)
        else
          factory.new(input, context)
        end
      end

      private

      attr_reader :factory
    end
  end
end
