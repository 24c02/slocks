# frozen_string_literal: true

module Slocks
  class ModalBuilder < BlocksBuilder
    attr_reader :modal_title, :submit_text, :close_text, :callback_id

    def title(text)
      @modal_title = text
    end

    def submit(text)
      @submit_text = text
    end

    def close(text)
      @close_text = text
    end

    def callback(id)
      @callback_id = id
    end

    def to_h
      modal = {
        type: "modal",
        title: { type: "plain_text", text: @modal_title },
        blocks: @blocks,
        callback_id: @callback_id
      }.compact
      modal[:submit] = { type: "plain_text", text: @submit_text } if @submit_text
      modal[:close] = { type: "plain_text", text: @close_text } if @close_text
      modal
    end
  end
end
