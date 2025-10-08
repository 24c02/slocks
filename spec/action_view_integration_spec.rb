# frozen_string_literal: true

require "json"
require "action_view"
require "slocks/template_handler"
require "slocks/action_view_monkeys"

RSpec.describe "ActionView Integration" do
  before do
    ActionView::Template.register_template_handler(:slack_blocks, Slocks::TemplateHandler)
    ActionView::Template.register_template_handler(:slack_modal, Slocks::ModalTemplateHandler)
  end

  let(:view) { ActionView::Base.with_empty_template_cache.new(ActionView::LookupContext.new([]), {}, nil) }

  describe "slack_blocks template handler" do
    it "generates code that creates blocks" do
      template = double(source: 'header "Welcome"')
      code = Slocks::TemplateHandler.call(template)

      expect(code).to include("Slocks::BlocksBuilder.new(self)")
      expect(code).to include('header "Welcome"')
      expect(code).to include("{ blocks: @__slocks_builder.blocks }")
    end

    it "renders inline template and converts to JSON string" do
      rendered = view.render(inline: 'header "Welcome"', type: :slack_blocks)

      expect(rendered).to be_a(String)
      parsed = JSON.parse(rendered)
      expect(parsed).to have_key("blocks")
      expect(parsed["blocks"]).to be_an(Array)
      expect(parsed["blocks"][0]["type"]).to eq("header")
      expect(parsed["blocks"][0]["text"]["text"]).to eq("Welcome")
    end

    it "supports instance variables in inline templates" do
      view.instance_variable_set(:@title, "Dynamic Title")
      view.instance_variable_set(:@message, "Dynamic Message")

      rendered = view.render(inline: <<~SLOCKS, type: :slack_blocks)
        header @title
        section @message
      SLOCKS

      parsed = JSON.parse(rendered)
      expect(parsed["blocks"][0]["text"]["text"]).to eq("Dynamic Title")
      expect(parsed["blocks"][1]["text"]["text"]).to eq("Dynamic Message")
    end

    it "supports multiple blocks" do
      rendered = view.render(inline: <<~SLOCKS, type: :slack_blocks)
        header "Welcome"
        section "Section 1"
        divider
        section "Section 2"
      SLOCKS

      parsed = JSON.parse(rendered)
      expect(parsed["blocks"].length).to eq(4)
      expect(parsed["blocks"][0]["type"]).to eq("header")
      expect(parsed["blocks"][1]["type"]).to eq("section")
      expect(parsed["blocks"][2]["type"]).to eq("divider")
      expect(parsed["blocks"][3]["type"]).to eq("section")
    end
  end

  describe "slack_modal template handler" do
    it "generates code that creates modals" do
      template = double(source: 'title "Test Modal"')
      code = Slocks::ModalTemplateHandler.call(template)

      expect(code).to include("Slocks::ModalBuilder.new(self)")
      expect(code).to include('title "Test Modal"')
      expect(code).to include("@__slocks_modal_builder.to_h")
    end

    it "renders inline template and converts to JSON string" do
      rendered = view.render(inline: <<~SLOCKS, type: :slack_modal)
        title "Test Modal"
        submit "Submit"
        close "Cancel"
      SLOCKS

      expect(rendered).to be_a(String)
      parsed = JSON.parse(rendered)
      expect(parsed["type"]).to eq("modal")
      expect(parsed["title"]["text"]).to eq("Test Modal")
      expect(parsed["submit"]["text"]).to eq("Submit")
      expect(parsed["close"]["text"]).to eq("Cancel")
      expect(parsed["blocks"]).to be_an(Array)
    end

    it "supports instance variables in inline templates" do
      view.instance_variable_set(:@modal_title, "Custom Modal")
      view.instance_variable_set(:@submit_text, "Save Changes")

      rendered = view.render(inline: <<~SLOCKS, type: :slack_modal)
        title @modal_title
        submit @submit_text
      SLOCKS

      parsed = JSON.parse(rendered)
      expect(parsed["title"]["text"]).to eq("Custom Modal")
      expect(parsed["submit"]["text"]).to eq("Save Changes")
    end
  end

  describe "template handler registration" do
    it "registers slack_blocks handler" do
      expect(ActionView::Template.handler_for_extension(:slack_blocks)).to eq(Slocks::TemplateHandler)
    end

    it "registers slack_modal handler" do
      expect(ActionView::Template.handler_for_extension(:slack_modal)).to eq(Slocks::ModalTemplateHandler)
    end
  end

  describe "JSON conversion monkey patch" do
    it "prepends JSONizer to ActionView::TemplateRenderer" do
      expect(ActionView::TemplateRenderer.ancestors).to include(Slocks::TemplateRenderer::JSONizer)
    end

    it "converts blocks template output to JSON" do
      rendered = view.render(inline: 'header "Test"', type: :slack_blocks)

      expect(rendered).to be_a(String)
      expect { JSON.parse(rendered) }.not_to raise_error

      parsed = JSON.parse(rendered)
      expect(parsed).to have_key("blocks")
    end

    it "converts modal template output to JSON" do
      rendered = view.render(inline: 'title "Test"', type: :slack_modal)

      expect(rendered).to be_a(String)
      expect { JSON.parse(rendered) }.not_to raise_error

      parsed = JSON.parse(rendered)
      expect(parsed).to have_key("type")
      expect(parsed["type"]).to eq("modal")
    end
  end
end
