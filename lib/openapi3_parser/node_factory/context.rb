# frozen_string_literal: true

module Openapi3Parser
  module NodeFactory
    # This class is used to specify the data and source information for a
    # NodeFactory. The same NodeFactory can be used multiple times if the
    # object is referenced so it is limited in data about it's location
    # within the document.
    #
    # @attr_reader  [Source::Location]        source_location
    # @attr_reader  [Array<Source::Location>] refernce_locations
    #
    class Context
      # Create a context for the root of a document
      #
      # @param  [Source]  source
      # @return [Context]
      def self.root(source)
        new(source_location: Source::Location.new(source, []))
      end

      # Create a factory context for a field within the current contexts data
      # eg for a context of:
      #   root = Context.root({ "test" => {} }, source)
      # we can get the context of "test" with:
      #   test = Context.next_field(root, "test")
      #
      # @param  [Context] parent_context
      # @param  [String]  field
      # @return [Context]
      def self.next_field(parent_context, field)
        source_location = Source::Location.next_field(
          parent_context.source_location, field
        )
        new(source_location: source_location,
            reference_locations: parent_context.reference_locations)
      end

      # Creates the context for a field that references another field
      #
      # @param  [Context]           reference_context
      # @param  [Source::Location]  source_location
      # @return [Context]
      def self.resolved_reference(reference_context, source_location:)
        reference_locations = [reference_context.source_location] +
                              reference_context.reference_locations

        new(source_location: source_location,
            reference_locations: reference_locations)
      end

      attr_reader :source_location, :reference_locations

      # @param  [Source::Location]        source_location
      # @param  [Array<Source::Location>] reference_locations
      def initialize(source_location:,
                     reference_locations: [])
        @source_location = source_location
        @reference_locations = reference_locations
      end

      # @return [Boolean]
      def ==(other)
        source_location == other.source_location &&
          reference_locations == other.reference_locations
      end

      # @return [Source]
      def source
        source_location.source
      end

      # @param  [String]              reference
      # @param  [Object, Map, Array]  factory
      # @param  [Boolean]             recursive
      # @return [Source::ResolvedReference]
      def resolve_reference(reference, factory, recursive: false)
        source.resolve_reference(reference, factory, self, recursive: recursive)
      end

      # Used to show when an recursive reference loop has begun
      #
      # @return [Boolean]
      def self_referencing?
        reference_locations.include?(source_location)
      end

      def inspect
        %{#{self.class.name}(source_location: #{source_location}, } +
          %{referenced_by: #{reference_locations.map(&:to_s).join(', ')})}
      end

      def location_summary
        source_location.to_s
      end

      def to_s
        location_summary
      end
    end
  end
end
