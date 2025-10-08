# frozen_string_literal: true

RSpec.describe Slocks::ModalBuilder do
  let(:context) { double("view_context") }
  let(:builder) { described_class.new(context) }

  describe "#title" do
    it "sets the modal title" do
      builder.title "My Modal"
      expect(builder.modal_title).to eq("My Modal")
    end
  end

  describe "#submit" do
    it "sets the submit button text" do
      builder.submit "Save"
      expect(builder.submit_text).to eq("Save")
    end
  end

  describe "#close" do
    it "sets the close button text" do
      builder.close "Cancel"
      expect(builder.close_text).to eq("Cancel")
    end
  end

  describe "#callback" do
    it "sets the callback_id" do
      builder.callback "modal_callback"
      expect(builder.callback_id).to eq("modal_callback")
    end
  end

  describe "#to_h" do
    it "builds a complete modal hash" do
      builder.title "Test Modal"
      builder.submit "Submit"
      builder.close "Cancel"
      builder.callback "test_callback"
      builder.section("Modal content")

      modal = builder.to_h
      expect(modal[:type]).to eq("modal")
      expect(modal[:title][:text]).to eq("Test Modal")
      expect(modal[:submit][:text]).to eq("Submit")
      expect(modal[:close][:text]).to eq("Cancel")
      expect(modal[:callback_id]).to eq("test_callback")
      expect(modal[:blocks].length).to eq(1)
    end

    it "omits optional fields if not set" do
      builder.title "Minimal Modal"
      modal = builder.to_h
      expect(modal[:submit]).to be_nil
      expect(modal[:close]).to be_nil
      expect(modal[:callback_id]).to be_nil
    end
  end
end
