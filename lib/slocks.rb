# frozen_string_literal: true

require_relative "slocks/version"
require_relative "slocks/rich_text_builder"
require_relative "slocks/blocks_builder"
require_relative "slocks/modal_builder"
require_relative "slocks/template_handler"
require_relative "slocks/railtie" if defined?(Rails::Railtie)

module Slocks
  class Error < StandardError; end
end
