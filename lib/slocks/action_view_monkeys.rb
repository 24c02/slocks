# frozen_string_literal: true

module Slocks
  module TemplateRenderer
    module JSONizer
      def render_template(_view, template, *)
        rendered_template = super
        if template.respond_to?(:handler) && [
          Slocks::TemplateHandler, Slocks::ModalTemplateHandler, Slocks::TemplateHandlerDispatcher
        ].include?(template.handler)
          rendered_template.instance_variable_set :@body,
                                                  rendered_template.body.to_json
        end
        rendered_template
      end
    end
  end

  class TemplateResult < SimpleDelegator
    def to_s
      __getobj__
    end
  end

  module CollectionRendererExtension
    private

    def render_collection(_collection, _view, _path, template, _layout, _block)
      obj = super
      if template.respond_to?(:handler) && [Slocks::TemplateHandler, Slocks::ModalTemplateHandler, Slocks::TemplateHandlerDispatcher].include?(template.handler)
        if obj.is_a?(ActionView::AbstractRenderer::RenderedCollection::EmptyCollection)
          def obj.body = []
        else
          def obj.body = @rendered_templates.map(&:body)
        end
      end
      obj
    end
  end

  module PartialRendererExtension
    private

    def render_collection(_view, template)
      obj = super
      if template.respond_to?(:handler) && [Slocks::TemplateHandler, Slocks::ModalTemplateHandler, Slocks::TemplateHandlerDispatcher].include?(template.handler)
        if obj.is_a?(ActionView::AbstractRenderer::RenderedCollection::EmptyCollection)
          def obj.body = []
        else
          def obj.body = @rendered_templates.map(&:body)
        end
      end
      obj
    end
  end
end

::ActionView::TemplateRenderer.prepend ::Slocks::TemplateRenderer::JSONizer
begin
  ::ActionView::CollectionRenderer.prepend ::Slocks::CollectionRendererExtension
rescue NameError
  ::ActionView::PartialRenderer.prepend ::Slocks::PartialRendererExtension
end
