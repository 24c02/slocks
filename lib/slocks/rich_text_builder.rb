# frozen_string_literal: true

module Slocks
  class RichTextBuilder
    attr_reader :elements

    def initialize
      @elements = []
    end

    def section(&block)
      section_builder = RichTextSectionBuilder.new
      section_builder.instance_eval(&block) if block_given?
      @elements << {
        type: "rich_text_section",
        elements: section_builder.elements
      }
    end

    def list(style:, &block)
      list_builder = RichTextSectionBuilder.new
      list_builder.instance_eval(&block) if block_given?
      @elements << {
        type: "rich_text_list",
        style: style,
        elements: list_builder.elements
      }
    end

    def preformatted(&block)
      section_builder = RichTextSectionBuilder.new
      section_builder.instance_eval(&block) if block_given?
      @elements << {
        type: "rich_text_preformatted",
        elements: section_builder.elements
      }
    end

    def quote(&block)
      section_builder = RichTextSectionBuilder.new
      section_builder.instance_eval(&block) if block_given?
      @elements << {
        type: "rich_text_quote",
        elements: section_builder.elements
      }
    end
  end

  class RichTextSectionBuilder
    attr_reader :elements

    def initialize
      @elements = []
    end

    def text(text, bold: nil, italic: nil, strike: nil, code: nil)
      element = { type: "text", text: text }
      style = {}
      style[:bold] = true if bold
      style[:italic] = true if italic
      style[:strike] = true if strike
      style[:code] = true if code
      element[:style] = style unless style.empty?
      @elements << element
    end

    def link(url, text: nil, unsafe: nil, style: nil)
      element = { type: "link", url: url }
      element[:text] = text if text
      element[:unsafe] = unsafe if unsafe
      element[:style] = style if style
      @elements << element
    end

    def emoji(name)
      @elements << { type: "emoji", name: name }
    end

    def channel(channel_id)
      @elements << { type: "channel", channel_id: channel_id }
    end

    def user(user_id)
      @elements << { type: "user", user_id: user_id }
    end

    def usergroup(usergroup_id)
      @elements << { type: "usergroup", usergroup_id: usergroup_id }
    end

    def date(timestamp, format:, fallback: nil, link: nil)
      element = { type: "date", timestamp: timestamp, format: format }
      element[:fallback] = fallback if fallback
      element[:link] = link if link
      @elements << element
    end

    def broadcast(range:)
      @elements << { type: "broadcast", range: range }
    end
  end
end
