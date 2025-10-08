# frozen_string_literal: true

require "active_support/core_ext/class/attribute"

module Slocks
  class TemplateHandlerDispatcher
    def self.call(template, source = nil)
      case template.format&.to_sym
      when :slack_modal
        ModalTemplateHandler.call(template, source)
      else
        BlocksTemplateHandler.call(template, source)
      end
    end
    
    def self.default_format = :slack_message
    def self.handles_encoding? = true
    
    def self.translate_location(spot, backtrace_location, source)
      BlocksTemplateHandler.translate_location(spot, backtrace_location, source)
    end
  end

  class BlocksTemplateHandler
    class << self
      def default_format = :slack_message

      def preamble = <<~EOP


        @__slocks_builder ||= Slocks::BlocksBuilder.new(self)
        def method_missing(m, *a, **k, &b)
          @__slocks_builder.respond_to?(m) ? @__slocks_builder.public_send(m, *a, **k, &b) : super
        end
      EOP

      def call(template, source = nil)
        source ||= template.source
        <<~EOS
          #{preamble}
          #{source}
          { blocks: @__slocks_builder.blocks }
        EOS
      end

      def translate_location(spot, _backtrace_location, _source)
        # eat your heart out rails-core
        # this sucks but seems to work
        plen = preamble.lines.size + 2
        spot[:first_lineno] -= plen
        spot[:last_lineno] -= plen
        spot[:script_lines] = spot[:script_lines][plen..-4]
        spot
      end

      def handles_encoding? = true
    end
  end

  class ModalTemplateHandler < BlocksTemplateHandler
    class << self
      def default_format = :slack_modal

      def call(template, source = nil)
        source ||= template.source
        <<~EOS
          @__slocks_modal_builder ||= Slocks::ModalBuilder.new(self)
          def method_missing(m, *a, **k, &b);
             @__slocks_modal_builder.respond_to?(m) ? @__slocks_modal_builder.public_send(m, *a, **k, &b) : super;
          end
          #{source}
          @__slocks_modal_builder.to_h
        EOS
      end
    end
  end
  
  TemplateHandler = BlocksTemplateHandler
end
