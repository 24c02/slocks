# frozen_string_literal: true

require "action_view"

module Slocks
  class Railtie < ::Rails::Railtie
    initializer "slocks.register_template_handler" do
      ActiveSupport.on_load(:action_view) do
        require "slocks/action_view_monkeys"
        require "slocks/template_handler"
        
        Mime::Type.register "application/json", :slack_message
        Mime::Type.register "application/json", :slack_modal
        
        ActionView::Template.register_template_handler(:slocks, Slocks::TemplateHandlerDispatcher)
      end
    end
  end
end
