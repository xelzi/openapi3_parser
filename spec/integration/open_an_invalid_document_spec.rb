# frozen_string_literal: true

require "openapi3_parser"

RSpec.describe "Open an invalid document" do
  subject(:document) { Openapi3Parser.load(input) }

  let(:input) do
    {
      openapi: "3.0.0",
      info: {
        title: "Test Document",
        version: "1.0.0"
      },
      paths: {},
      components: {
        examples: {
          test: { extra: "field" }
        }
      }
    }
  end

  it { is_expected.not_to be_valid }

  it "raises an exception accessing the erroneous node" do
    expect { document.openapi }.not_to raise_error
    expect { document.components.examples["test"] }
      .to raise_error(Openapi3Parser::Error)
  end
end
