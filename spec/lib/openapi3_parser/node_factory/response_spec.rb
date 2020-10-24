# frozen_string_literal: true

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::Response do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Response do
    let(:input) do
      {
        "description" => "A simple string response",
        "content" => {
          "text/plain" => {
            "schema" => {
              "type" => "string"
            }
          }
        },
        "headers" => {
          "X-Rate-Limit-Limit" => {
            "description" => "The number of allowed requests in the current"\
                             " period",
            "schema" => { "type" => "integer" }
          },
          "X-Rate-Limit-Remaining" => {
            "description" => "The number of remaining requests in the current"\
                             " period",
            "schema" => { "type" => "integer" }
          },
          "X-Rate-Limit-Reset" => {
            "description" => "The number of seconds left in the current"\
                             " period",
            "schema" => { "type" => "integer" }
          }
        }
      }
    end

    let(:node_factory_context) { create_node_factory_context(input) }
    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  describe "content" do
    subject { described_class.new(node_factory_context) }

    let(:node_factory_context) do
      create_node_factory_context({ "description" => "Description",
                                    "content" => content })
    end

    context "when content is an empty hash" do
      let(:content) { {} }

      it { is_expected.to be_valid }
    end

    context "when content has a valid media type" do
      let(:content) do
        {
          "application/json" => {}
        }
      end

      it { is_expected.to be_valid }
    end

    context "when content has an invalid valid media type" do
      let(:content) do
        {
          "bad-media-type" => {}
        }
      end

      it do
        expect(subject)
          .to have_validation_error("#/content/bad-media-type")
          .with_message(%("bad-media-type" is not a valid media type))
      end
    end
  end

  describe "links" do
    subject { described_class.new(node_factory_context) }

    let(:node_factory_context) do
      create_node_factory_context(
        {
          "description" => "Description",
          "links" => { key => { "operationRef" => "#/test" } }
        }
      )
    end

    context "when key is invalid" do
      let(:key) { "Invalid Key" }

      it { is_expected.not_to be_valid }
    end

    context "when key is valid" do
      let(:key) { "valid.key" }

      it { is_expected.to be_valid }
    end
  end
end
