# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::MediaType do
  it_behaves_like "node object factory", Openapi3Parser::Node::MediaType do
    let(:input) do
      {
        "schema" => {
          "$ref" => "#/components/schemas/Pet"
        },
        "examples" => {
          "cat" => {
            "summary" => "An example of a cat",
            "value" => {
              "name" => "Fluffy",
              "petType" => "Cat",
              "color" => "White",
              "gender" => "male",
              "breed" => "Persian"
            }
          },
          "dog" => {
            "summary" => "An example of a dog with a cat's name",
            "value" => {
              "name" => "Puma",
              "petType" => "Dog",
              "color" => "Black",
              "gender" => "Female",
              "breed" => "Mixed"
            }
          }
        }
      }
    end

    let(:document_input) do
      {
        "components" => {
          "schemas" => {
            "Pet" => {
              "type" => "object",
              "discriminator" => { "propertyName" => "petType" },
              "properties" => {
                "name" => { "type" => "string" },
                "petType" => { "type" => "string" }
              },
              "required" => %w[name petType]
            }
          }
        }
      }
    end

    let(:node_factory_context) do
      create_node_factory_context(input, document_input: document_input)
    end
  end

  it_behaves_like "mutually exclusive example"

  describe "examples default value" do
    it "defaults to a value of nil" do
      factory_context = create_node_factory_context({})
      node = described_class.new(factory_context).node(
        node_factory_context_to_node_context(factory_context)
      )
      expect(node["examples"]).to be_nil
    end
  end

  describe "encoding" do
    subject(:instance) { described_class.new(node_factory_context) }

    let(:node_factory_context) do
      create_node_factory_context({ "schema" => schema,
                                    "encoding" => encoding })
    end

    let(:schema) do
      {
        "type" => "object",
        "properties" => {
          "name" => { "type" => "string" },
          "field" => { "type" => "string" }
        }
      }
    end

    context "when the keys exist in the schema" do
      let(:encoding) do
        {
          "name" => { "contentType" => "text/plain" }
        }
      end

      it { is_expected.to be_valid }
    end

    context "when keys don't exist as properties in the schema" do
      let(:encoding) do
        {
          "key_1" => { "contentType" => "text/plain" },
          "key_2" => { "contentType" => "text/plain" }
        }
      end

      it do
        expect(instance)
          .to have_validation_error("#/encoding")
          .with_message(
            "Keys are not defined as schema properties: key_1, key_2"
          )
      end
    end

    context "when there is a malformed schema" do
      let(:schema) do
        {
          "properties" => []
        }
      end
      let(:encoding) { {} }

      it { is_expected.not_to be_valid }
      it { is_expected.not_to have_validation_error("#/encoding") }
    end
  end
end
