# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Openapi do
  let(:minimal_openapi_definition) do
    {
      "openapi" => "3.0.0",
      "info" => {
        "title" => "Minimal Openapi definition",
        "version" => "1.0.0"
      },
      "paths" => {}
    }
  end

  it_behaves_like "node object factory", Openapi3Parser::Node::Openapi do
    let(:input) { minimal_openapi_definition }
  end

  context "when input is nil" do
    let(:factory_context) { create_node_factory_context(nil) }

    it "is invalid" do
      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/")
        .with_message("Invalid type. Expected Object")
    end

    it "raises an error trying to access the node" do
      instance = described_class.new(factory_context)
      node_context = node_factory_context_to_node_context(factory_context)
      expect { instance.node(node_context) }.to raise_error(Openapi3Parser::Error)
    end
  end

  describe "validating tags" do
    it "is valid when tags contain no duplicates" do
      factory_context = create_node_factory_context(
        minimal_openapi_definition.merge(
          "tags" => [{ "name" => "a" }, { "name" => "b" }]
        )
      )
      expect(described_class.new(factory_context)).to be_valid
    end

    it "is invalid for an invalid key" do
      factory_context = create_node_factory_context(
        minimal_openapi_definition.merge(
          "tags" => [{ "name" => "a" }, { "name" => "a" }]
        )
      )

      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/tags")
        .with_message("Duplicate tag names: a")
    end
  end

  describe "servers" do
    subject(:node) do
      input = minimal_openapi_definition.merge("servers" => servers)
      node_factory_context = create_node_factory_context(input)
      node_context = node_factory_context_to_node_context(node_factory_context)
      described_class.new(node_factory_context)
                     .node(node_context)
    end

    shared_examples "defaults to a single root server" do
      # As per: https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.2.md#fixed-fields
      it "has an array with a root server" do
        servers = node["servers"]
        expect(servers.length).to be 1
        expect(servers[0]).to be_a(Openapi3Parser::Node::Server)
        expect(servers[0].url).to eq "/"
        expect(servers[0].description).to be_nil
      end
    end

    context "when servers are not provided" do
      let(:servers) { nil }

      include_examples "defaults to a single root server"
    end

    context "when servers are an empty array" do
      let(:servers) { [] }

      include_examples "defaults to a single root server"
    end

    context "when servers are set" do
      let(:servers) do
        [
          {
            "url" => "https://development.gigantic-server.com/v1",
            "description" => "Development server"
          }
        ]
      end

      it "has an array with the server value" do
        servers = node["servers"]
        expect(servers.length).to be 1
        expect(servers[0]).to be_a(Openapi3Parser::Node::Server)
        expect(servers[0].description).to eq "Development server"
      end
    end
  end
end
