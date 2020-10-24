# frozen_string_literal: true

require "support/default_field"
require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::Schema do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Schema do
    let(:input) do
      {
        "allOf" => [
          { "$ref" => "#/components/schemas/Pet" },
          {
            "type" => "object",
            "properties" => {
              "bark" => { "type" => "string" }
            }
          }
        ]
      }
    end

    let(:document_input) do
      {
        "components" => {
          "schemas" => {
            "Pet" => {
              "type" => "object",
              "required" => %w[pet_type],
              "properties" => {
                "pet_type" => { "type" => "string" }
              },
              "discriminator" => {
                "propertyName" => "pet_type",
                "mapping" => { "cachorro" => "Dog" }
              }
            }
          }
        }
      }
    end

    let(:node_factory_context) do
      create_node_factory_context(input, document_input: document_input)
    end

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  describe "items" do
    subject { described_class.new(node_factory_context) }

    let(:node_factory_context) do
      create_node_factory_context({ "type" => type, "items" => items })
    end

    context "when type is not array and items is not provided" do
      let(:type) { "string" }
      let(:items) { nil }

      it { is_expected.to be_valid }
    end

    context "when type is array and items is not provided" do
      let(:type) { "array" }
      let(:items) { nil }

      it do
        expect(subject)
          .to have_validation_error("#/")
          .with_message("items must be defined for a type of array")
      end
    end

    context "when type is array and items areprovided" do
      let(:type) { "array" }
      let(:items) { { "type" => "string" } }

      it { is_expected.to be_valid }
    end
  end

  describe "writeOnly and readOnly" do
    subject { described_class.new(node_factory_context) }

    let(:node_factory_context) do
      create_node_factory_context({ "readOnly" => read_only,
                                    "writeOnly" => write_only })
    end

    context "when both are true" do
      let(:read_only) { true }
      let(:write_only) { true }

      it do
        expect(subject)
          .to have_validation_error("#/")
          .with_message("readOnly and writeOnly cannot both be true")
      end
    end
  end

  it_behaves_like "default field", field: "nullable", defaults_to: false do
    let(:node_factory_context) do
      create_node_factory_context({ "nullable" => nullable })
    end

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  it_behaves_like "default field",
                  field: "readOnly",
                  defaults_to: false,
                  var_name: :read_only do
    let(:node_factory_context) do
      create_node_factory_context({ "readOnly" => read_only })
    end

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  it_behaves_like "default field",
                  field: "writeOnly",
                  defaults_to: false,
                  var_name: :write_only do
    let(:node_factory_context) do
      create_node_factory_context({ "writeOnly" => write_only })
    end

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  it_behaves_like "default field",
                  field: "deprecated",
                  defaults_to: false,
                  var_name: :deprecated do
    let(:node_factory_context) do
      create_node_factory_context({ "deprecated" => deprecated })
    end

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  describe "additionalProperties" do
    subject do
      context = create_node_factory_context(
        { "additionalProperties" => additional_properties }
      )

      described_class.new(context)
    end

    context "when it is set to true" do
      let(:additional_properties) { true }

      it { is_expected.to be_valid }
    end

    context "when it is set to false" do
      let(:additional_properties) { false }

      it { is_expected.to be_valid }
    end

    context "when it is an object" do
      let(:additional_properties) { { "type" => "object" } }

      it { is_expected.to be_valid }
    end

    context "when it is something different" do
      let(:additional_properties) { %w[item_1 item_2] }

      it do
        expect(subject)
          .to have_validation_error("#/additionalProperties")
          .with_message("Expected a Boolean or an Object")
      end
    end
  end
end
