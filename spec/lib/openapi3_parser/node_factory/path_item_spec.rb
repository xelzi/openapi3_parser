# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::PathItem do
  it_behaves_like "node object factory", Openapi3Parser::Node::PathItem do
    let(:input) do
      {
        "summary" => "Example",
        "get" => {
          "description" => "Returns pets based on ID",
          "summary" => "Find pets by ID",
          "operationId" => "getPetsById",
          "responses" => {
            "200" => {
              "description" => "pet response",
              "content" => {
                "*/*" => {
                  "schema" => {
                    "type" => "array",
                    "items" => { "type" => "string" }
                  }
                }
              }
            },
            "default" => {
              "description" => "error payload",
              "content" => {
                "text/html" => {
                  "schema" => { "type" => "string" }
                }
              }
            }
          }
        },
        "parameters" => [
          {
            "name" => "id",
            "in" => "path",
            "description" => "ID of pet to use",
            "required" => true,
            "schema" => {
              "type" => "array",
              "items" => {
                "type" => "string"
              }
            },
            "style" => "simple"
          }
        ],
        "servers" => [
          {
            "url" => "https://development.gigantic-server.com/v1",
            "description" => "Development server"
          }
        ]
      }
    end
  end

  describe "parameters" do
    subject do
      described_class.new(
        create_node_factory_context({ "parameters" => parameters })
      )
    end

    context "when there are no duplicate parameters" do
      let(:parameters) do
        [
          { "name" => "id", "in" => "header" },
          { "name" => "id", "in" => "query" }
        ]
      end

      it { is_expected.to be_valid }
    end

    context "when there are duplicate parameters" do
      let(:parameters) do
        [
          { "name" => "id", "in" => "query" },
          { "name" => "id", "in" => "query" }
        ]
      end

      it { is_expected.not_to be_valid }
    end
  end

  describe "merging with reference" do
    let(:input) do
      { "$ref" => "#/path_items/example" }
    end

    let(:document_input) do
      {
        "path_items" => { "example" => reference_input }
      }
    end

    let(:node_factory_context) do
      create_node_factory_context(input, document_input: document_input)
    end

    let(:reference_input) do
      {
        "summary" => "My summary",
        "parameters" => [
          { "name" => "id", "in" => "query" }
        ],
        "servers" => [{ "url" => "/" }]
      }
    end

    let(:instance) { described_class.new(node_factory_context) }

    let(:node) do
      node_context = node_factory_context_to_node_context(node_factory_context)
      instance.node(node_context)
    end

    it "can be accessed via resolved_input" do
      expect(instance.resolved_input).to match(
        hash_including(
          "summary" => "My summary",
          "parameters" => [
            hash_including("name" => "id", "in" => "query")
          ]
        )
      )
    end

    it "is within the node" do
      expect(node.summary).to eq "My summary"
      expect(node.parameters[0].name).to eq "id"
    end

    context "when both structures contain the same field" do
      let(:input) do
        {
          "$ref" => "#/path_items/example",
          "summary" => "A different summary"
        }
      end

      it "uses the input at a higher priority than the reference" do
        expect(instance.resolved_input).to match(
          hash_including("summary" => "A different summary")
        )

        expect(node.summary).to eq "A different summary"
      end
    end

    context "when the input is only a reference" do
      it "deems the source location to be that of the reference" do
        expect(node.node_context.source_location.to_s)
          .to eq "#/path_items/example"
      end
    end

    context "when the input is not only a reference" do
      let(:input) do
        {
          "$ref" => "#/path_items/example",
          "summary" => "A different summary"
        }
      end

      it "deems the source location to be that of the original node" do
        expect(node.node_context.source_location.to_s).to eq "#/"
      end
    end
  end

  describe "servers" do
    let(:document_input) do
      {
        "openapi" => "3.0.0",
        "info" => {
          "title" => "Minimal Openapi definition",
          "version" => "1.0.0"
        },
        "paths" => {
          "/test" => input
        },
        "servers" => [
          {
            "url" => "https://dev.example.com/v1",
            "description" => "Development server"
          }
        ]
      }
    end

    let(:node_factory_context) do
      create_node_factory_context(input,
                                  document_input: document_input,
                                  pointer_segments: %w[paths /test])
    end

    let(:instance) { described_class.new(node_factory_context) }

    let(:node) do
      node_context = node_factory_context_to_node_context(node_factory_context)
      instance.node(node_context)
    end

    shared_examples "defaults to servers from root object" do
      it "uses the servers from the root object" do
        expect(node["servers"][0].url).to eq "https://dev.example.com/v1"
        expect(node["servers"][0].description).to eq "Development server"
      end
    end

    context "when servers is nil" do
      let(:input) { { "servers" => nil } }

      include_examples "defaults to servers from root object"
    end

    context "when servers is an empty array" do
      let(:input) { { "servers" => [] } }

      include_examples "defaults to servers from root object"
    end

    context "when servers are provided" do
      let(:input) do
        {
          "servers" => [
            {
              "url" => "https://prod.example.com/v1",
              "description" => "Production server"
            }
          ]
        }
      end

      it "uses it's defined servers" do
        expect(node["servers"][0].url).to eq "https://prod.example.com/v1"
        expect(node["servers"][0].description).to eq "Production server"
      end
    end
  end
end
