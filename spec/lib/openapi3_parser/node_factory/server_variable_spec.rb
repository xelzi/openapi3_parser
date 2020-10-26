# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::ServerVariable do
  it_behaves_like "node object factory", Openapi3Parser::Node::ServerVariable do
    let(:input) do
      {
        "enum" => %w[8443 443],
        "default" => "8443"
      }
    end
  end

  describe "enum" do
    subject(:factory) { described_class.new(node_factory_context) }

    let(:node_factory_context) do
      create_node_factory_context({ "enum" => enum, "default" => "test" })
    end

    context "when enum is not empty" do
      let(:enum) { %w[test] }

      it { is_expected.to be_valid }
    end

    context "when enum is empty" do
      let(:enum) { [] }

      it { is_expected.to have_validation_error("#/enum") }
    end
  end
end
