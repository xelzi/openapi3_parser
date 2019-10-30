# frozen_string_literal: true

RSpec.shared_examples "node object factory" do |klass|
  describe "#node" do
    subject do
      described_class.new(input, node_factory_context).node(node_context)
    end
    it { is_expected.to be_a(klass) }
  end

  describe "#valid?" do
    subject { described_class.new(input, node_factory_context).valid? }
    it { is_expected.to be true }
  end

  describe "#errors" do
    subject { described_class.new(input, node_factory_context).errors }
    it { is_expected.to be_empty }
  end
end
