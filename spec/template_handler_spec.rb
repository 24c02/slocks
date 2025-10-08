# frozen_string_literal: true

RSpec.describe Slocks::TemplateHandler do
  describe ".call" do
    it "returns Ruby code that builds blocks" do
      template = double(source: 'header "Test"')
      code = described_class.call(template)

      expect(code).to include("Slocks::BlocksBuilder.new(self)")
      expect(code).to include('header "Test"')
      expect(code).to include("{ blocks: @__slocks_builder.blocks }")
    end
  end

  describe ".handles_encoding?" do
    it "returns true" do
      expect(described_class.handles_encoding?).to be true
    end
  end

  describe ".default_format" do
    it "is :json" do
      expect(described_class.default_format).to eq(:json)
    end
  end

  describe ".translate_location" do
    it "adjusts line numbers by -1" do
      spot = { first_line: 5, last_line: 5 }
      result = described_class.translate_location(spot, nil, "")
      expect(result).to eq({ first_line: 4, last_line: 4 })
    end

    it "doesn't adjust line 1 or below" do
      spot = { first_line: 1, last_line: 1 }
      result = described_class.translate_location(spot, nil, "")
      expect(result).to eq({ first_line: 1, last_line: 1 })
    end
  end

  describe "line number preservation" do
    it "places user code starting at line 2 (after 1-line preamble)" do
      template = double(source: "# line 1\n# line 2\n# line 3")
      compiled = described_class.call(template)
      
      lines = compiled.split("\n")
      user_code_start = lines.index("# line 1")
      expect(user_code_start).to eq(1), "User code should start at index 1 (line 2)"
    end
  end
end

RSpec.describe Slocks::ModalTemplateHandler do
  describe ".call" do
    it "returns Ruby code that builds a modal" do
      template = double(source: 'title "Test Modal"')
      code = described_class.call(template)

      expect(code).to include("Slocks::ModalBuilder.new(self)")
      expect(code).to include('title "Test Modal"')
      expect(code).to include("builder.to_h")
    end
  end

  describe ".handles_encoding?" do
    it "returns true" do
      expect(described_class.handles_encoding?).to be true
    end
  end
end
