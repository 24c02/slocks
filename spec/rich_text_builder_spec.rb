# frozen_string_literal: true

RSpec.describe Slocks::RichTextBuilder do
  let(:builder) { described_class.new }

  describe "#section" do
    it "adds a rich_text_section element" do
      builder.section do
        text "Hello world"
      end

      expect(builder.elements.first[:type]).to eq("rich_text_section")
      expect(builder.elements.first[:elements].first[:type]).to eq("text")
      expect(builder.elements.first[:elements].first[:text]).to eq("Hello world")
    end
  end

  describe "#list" do
    it "adds a rich_text_list element" do
      builder.list(style: "bullet") do
        text "Item 1"
      end

      expect(builder.elements.first[:type]).to eq("rich_text_list")
      expect(builder.elements.first[:style]).to eq("bullet")
    end
  end
end

RSpec.describe Slocks::RichTextSectionBuilder do
  let(:builder) { described_class.new }

  describe "#text" do
    it "adds text element" do
      builder.text("Plain text")
      expect(builder.elements.first).to eq({ type: "text", text: "Plain text" })
    end

    it "adds styled text" do
      builder.text("Bold", bold: true, italic: true)
      expect(builder.elements.first[:style]).to eq({ bold: true, italic: true })
    end
  end

  describe "#link" do
    it "adds link element" do
      builder.link("https://example.com", text: "Example")
      expect(builder.elements.first[:type]).to eq("link")
      expect(builder.elements.first[:url]).to eq("https://example.com")
      expect(builder.elements.first[:text]).to eq("Example")
    end
  end

  describe "#emoji" do
    it "adds emoji element" do
      builder.emoji("smile")
      expect(builder.elements.first).to eq({ type: "emoji", name: "smile" })
    end
  end

  describe "#user" do
    it "adds user mention element" do
      builder.user("U123ABC")
      expect(builder.elements.first).to eq({ type: "user", user_id: "U123ABC" })
    end
  end

  describe "#channel" do
    it "adds channel link element" do
      builder.channel("C123ABC")
      expect(builder.elements.first).to eq({ type: "channel", channel_id: "C123ABC" })
    end
  end

  describe "#broadcast" do
    it "adds broadcast element" do
      builder.broadcast(range: "here")
      expect(builder.elements.first).to eq({ type: "broadcast", range: "here" })
    end
  end
end
