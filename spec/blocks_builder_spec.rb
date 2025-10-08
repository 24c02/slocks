# frozen_string_literal: true

RSpec.describe Slocks::BlocksBuilder do
  let(:context) { double("view_context") }
  let(:builder) { described_class.new(context) }

  describe "#header" do
    it "adds a header block" do
      builder.header "Test Header"
      expect(builder.blocks).to eq([
                                     {
                                       type: "header",
                                       text: {
                                         type: "plain_text",
                                         text: "Test Header"
                                       }
                                     }
                                   ])
    end
  end

  describe "#section" do
    it "adds a section block with text" do
      builder.section("Test section")
      expect(builder.blocks.first[:type]).to eq("section")
      expect(builder.blocks.first[:text][:text]).to eq("Test section")
    end

    it "supports markdown option" do
      builder.section("*Bold text*", markdown: true)
      expect(builder.blocks.first[:text][:type]).to eq("mrkdwn")
    end

    it "supports accessory" do
      accessory = { type: "button", text: { type: "plain_text", text: "Click" }, action_id: "test" }
      builder.section("Text", accessory: accessory)
      expect(builder.blocks.first[:accessory]).to eq(accessory)
    end
  end

  describe "#divider" do
    it "adds a divider block" do
      builder.divider
      expect(builder.blocks).to eq([{ type: "divider" }])
    end
  end

  describe "#context" do
    it "adds a context block with elements" do
      elements = [{ type: "mrkdwn", text: "Context text" }]
      builder.context(elements)
      expect(builder.blocks.first[:type]).to eq("context")
      expect(builder.blocks.first[:elements]).to eq(elements)
    end
  end

  describe "#context_actions" do
    it "adds a context_actions block with elements" do
      elements = [{ type: "feedback_buttons", action_id: "fb1" }]
      builder.context_actions(elements)
      expect(builder.blocks.first[:type]).to eq("context_actions")
      expect(builder.blocks.first[:elements]).to eq(elements)
    end

    it "supports block_id" do
      elements = [{ type: "icon_button", action_id: "ib1" }]
      builder.context_actions(elements, block_id: "ca_block_1")
      expect(builder.blocks.first[:block_id]).to eq("ca_block_1")
    end

    it "omits block_id when nil" do
      elements = [{ type: "feedback_buttons", action_id: "fb1" }]
      builder.context_actions(elements)
      expect(builder.blocks.first).not_to have_key(:block_id)
    end
  end

  describe "#image" do
    it "adds an image block" do
      builder.image("https://example.com/img.png", "Alt text")
      expect(builder.blocks.first[:type]).to eq("image")
      expect(builder.blocks.first[:image_url]).to eq("https://example.com/img.png")
      expect(builder.blocks.first[:alt_text]).to eq("Alt text")
    end
  end

  describe "#button" do
    it "creates a button element" do
      btn = builder.button("Click me", "btn_action")
      expect(btn[:type]).to eq("button")
      expect(btn[:text][:text]).to eq("Click me")
      expect(btn[:action_id]).to eq("btn_action")
    end

    it "supports style and url" do
      btn = builder.button("Click", "action", style: "primary", url: "https://example.com")
      expect(btn[:style]).to eq("primary")
      expect(btn[:url]).to eq("https://example.com")
    end
  end

  describe "#mrkdwn_text" do
    it "creates a mrkdwn text object" do
      text = builder.mrkdwn_text("*Bold*")
      expect(text).to eq({ type: "mrkdwn", text: "*Bold*" })
    end
  end

  describe "#plain_text" do
    it "creates a plain_text object" do
      text = builder.plain_text("Plain")
      expect(text).to eq({ type: "plain_text", text: "Plain", emoji: true })
    end
  end

  describe "#option" do
    it "creates an option object" do
      opt = builder.option("Label", "value1")
      expect(opt[:text][:text]).to eq("Label")
      expect(opt[:value]).to eq("value1")
    end
  end

  describe "#select_menu" do
    it "creates a select menu element" do
      options = [builder.option("Option 1", "val1")]
      menu = builder.select_menu("menu_action", placeholder: "Choose", options: options)
      expect(menu[:type]).to eq("static_select")
      expect(menu[:placeholder][:text]).to eq("Choose")
    end
  end

  describe "#feedback_buttons" do
    it "creates a feedback_buttons element" do
      fb = builder.feedback_buttons("👍", "positive", "👎", "negative", action_id: "fb_action")
      expect(fb[:type]).to eq("feedback_buttons")
      expect(fb[:action_id]).to eq("fb_action")
      expect(fb[:positive_button][:text][:text]).to eq("👍")
      expect(fb[:positive_button][:value]).to eq("positive")
      expect(fb[:negative_button][:text][:text]).to eq("👎")
      expect(fb[:negative_button][:value]).to eq("negative")
    end

    it "supports accessibility labels" do
      fb = builder.feedback_buttons("👍", "pos", "👎", "neg",
                                    positive_accessibility_label: "Good", negative_accessibility_label: "Bad")
      expect(fb[:positive_button][:accessibility_label]).to eq("Good")
      expect(fb[:negative_button][:accessibility_label]).to eq("Bad")
    end

    it "omits optional fields when nil" do
      fb = builder.feedback_buttons("👍", "pos", "👎", "neg")
      expect(fb).not_to have_key(:action_id)
      expect(fb[:positive_button]).not_to have_key(:accessibility_label)
    end
  end

  describe "#icon_button" do
    it "creates an icon_button element" do
      ib = builder.icon_button("trash", "Delete", "delete_action", value: "item_1")
      expect(ib[:type]).to eq("icon_button")
      expect(ib[:icon]).to eq("trash")
      expect(ib[:text][:text]).to eq("Delete")
      expect(ib[:action_id]).to eq("delete_action")
      expect(ib[:value]).to eq("item_1")
    end

    it "supports accessibility label and visible_to_user_ids" do
      ib = builder.icon_button("star", "Favorite", "fav", accessibility_label: "Add to favorites",
                               visible_to_user_ids: ["U123"])
      expect(ib[:accessibility_label]).to eq("Add to favorites")
      expect(ib[:visible_to_user_ids]).to eq(["U123"])
    end

    it "omits optional fields when nil" do
      ib = builder.icon_button("trash", "Delete", "delete_action")
      expect(ib).not_to have_key(:value)
      expect(ib).not_to have_key(:confirm)
    end
  end

  describe "helper delegation" do
    it "delegates unknown methods to context" do
      allow(context).to receive(:pluralize).with(5, "item").and_return("5 items")
      expect(builder.pluralize(5, "item")).to eq("5 items")
    end
  end
end
