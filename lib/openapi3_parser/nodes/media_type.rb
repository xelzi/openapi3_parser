# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Nodes
    class MediaType
      include Node::Object

      def schema
        node_data["schema"]
      end

      def example
        node_data["example"]
      end

      def examples
        node_data["examples"]
      end

      def encoding
        node_data["encoding"]
      end
    end
  end
end