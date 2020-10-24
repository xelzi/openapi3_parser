# frozen_string_literal: true

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::Responses do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Responses do
    let(:input) do
      {
        "200" => {
          "description" => "a pet to be returned",
          "content" => {
            "application/json" => {
              "schema" => { "type" => "string" }
            }
          }
        },
        "default" => {
          "description" => "Unexpected error",
          "content" => {
            "application/json" => {
              "schema" => { "type" => "string" }
            }
          }
        }
      }
    end

    let(:node_factory_context) { create_node_factory_context(input) }
    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  describe "valid keys" do
    subject { described_class.new(node_factory_context) }

    let(:response) do
      {
        "description" => "A response",
        "content" => {
          "application/json" => {
            "schema" => { "type" => "string" }
          }
        }
      }
    end
    let(:node_factory_context) do
      create_node_factory_context({ key_value => response })
    end

    context "when the key_value is a status code range" do
      let(:key_value) { "2XX" }

      it { is_expected.to be_valid }
    end

    context "when the key_value is a status code" do
      let(:key_value) { "503" }

      it { is_expected.to be_valid }
    end

    context "when the key_value is a random string" do
      let(:key_value) { "5tsd8s" }

      it do
        expect(subject)
          .to have_validation_error("#/")
          .with_message(
            "Invalid responses keys: '5tsd8s' - default, status codes and "\
            "status code ranges allowed"
          )
      end
    end

    context "when the key_value is an invalid status code" do
      let(:key_value) { "999" }

      it { is_expected.to have_validation_error("#/") }
    end
  end
end
