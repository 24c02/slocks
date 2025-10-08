# frozen_string_literal: true

module Slocks
  class BlocksBuilder
    attr_reader :blocks

    def initialize(context)
      @context = context
      @blocks = []
    end

    def header(text)
      @blocks << {
        type: "header",
        text: {
          type: "plain_text",
          text: text
        }
      }
    end

    def section(text = nil, accessory: nil, fields: nil, markdown: false)
      block = { type: "section" }

      if text
        block[:text] = {
          type: markdown ? "mrkdwn" : "plain_text",
          text: text
        }
      end

      block[:accessory] = accessory if accessory
      block[:fields] = fields if fields

      @blocks << block
    end

    def simple_section(text)
      section(text, markdown: true)
    end

    def divider
      @blocks << { type: "divider" }
    end

    def context(elements)
      @blocks << {
        type: "context",
        elements: elements
      }
    end

    def context_actions(elements, block_id: nil)
      @blocks << {
        type: "context_actions",
        elements:,
        block_id:
      }.compact
    end

    def actions(elements)
      @blocks << {
        type: "actions",
        elements: elements
      }
    end

    def image(image_url, alt_text, title: nil)
      block = {
        type: "image",
        image_url: image_url,
        alt_text: alt_text
      }
      block[:title] = { type: "plain_text", text: title } if title
      @blocks << block
    end

    def input(label, element, optional: false, hint: nil, block_id: nil, dispatch_action: nil)
      block = {
        type: "input",
        label: { type: "plain_text", text: label },
        element: element
      }
      block[:block_id] = block_id if block_id
      block[:optional] = optional if optional
      block[:hint] = { type: "plain_text", text: hint } if hint
      block[:dispatch_action] = dispatch_action if dispatch_action
      @blocks << block
    end

    def file(external_id, source: "remote", block_id: nil)
      block = {
        type: "file",
        external_id: external_id,
        source: source
      }
      block[:block_id] = block_id if block_id
      @blocks << block
    end

    def video(title, title_url, thumbnail_url, video_url, alt_text:, description: nil, author_name: nil,
              provider_name: nil, provider_icon_url: nil, block_id: nil)
      block = {
        type: "video",
        title: { type: "plain_text", text: title },
        title_url:,
        thumbnail_url:,
        video_url:,
        alt_text:,
        description: description ? { type: "plain_text", text: description } : nil,
        author_name:,
        provider_name:,
        provider_icon_url:,
        block_id:
      }.compact
      @blocks << block
    end

    def rich_text(&block)
      builder = RichTextBuilder.new
      builder.instance_eval(&block) if block_given?
      @blocks << {
        type: "rich_text",
        elements: builder.elements
      }
    end

    def image_element(image_url, alt_text)
      {
        type: "image",
        image_url: image_url,
        alt_text: alt_text
      }
    end

    def mrkdwn_text(text)
      {
        type: "mrkdwn",
        text: text
      }
    end

    def plain_text(text, emoji: true)
      {
        type: "plain_text",
        text: text,
        emoji: emoji
      }
    end

    def button(text, action_id, value: nil, url: nil, style: nil, confirm: nil, accessibility_label: nil)
      {
        type: "button",
        text: { type: "plain_text", text: text },
        action_id:,
        value:,
        url:,
        style:,
        confirm:,
        accessibility_label:
      }.compact
    end

    def checkboxes(action_id, options, initial_options: nil, confirm: nil, focus_on_load: nil)
      {
        type: "checkboxes",
        action_id:,
        options:,
        initial_options:,
        confirm:,
        focus_on_load:
      }.compact
    end

    def date_picker(action_id, placeholder: nil, initial_date: nil, confirm: nil, focus_on_load: nil)
      {
        type: "datepicker",
        action_id:,
        placeholder: placeholder ? { type: "plain_text", text: placeholder } : nil,
        initial_date:,
        confirm:,
        focus_on_load:
      }.compact
    end

    def datetime_picker(action_id, initial_date_time: nil, confirm: nil, focus_on_load: nil)
      {
        type: "datetimepicker",
        action_id:,
        initial_date_time:,
        confirm:,
        focus_on_load:
      }.compact
    end

    def time_picker(action_id, placeholder: nil, initial_time: nil, confirm: nil, focus_on_load: nil, timezone: nil)
      {
        type: "timepicker",
        action_id:,
        placeholder: placeholder ? { type: "plain_text", text: placeholder } : nil,
        initial_time:,
        confirm:,
        focus_on_load:,
        timezone:
      }.compact
    end

    def plain_text_input(action_id, placeholder: nil, initial_value: nil, multiline: nil, min_length: nil,
                         max_length: nil, dispatch_action_config: nil, focus_on_load: nil)
      {
        type: "plain_text_input",
        action_id:,
        placeholder: placeholder ? { type: "plain_text", text: placeholder } : nil,
        initial_value:,
        multiline:,
        min_length:,
        max_length:,
        dispatch_action_config:,
        focus_on_load:
      }.compact
    end

    def email_input(action_id, placeholder: nil, initial_value: nil, dispatch_action_config: nil, focus_on_load: nil)
      {
        type: "email_text_input",
        action_id:,
        placeholder: placeholder ? { type: "plain_text", text: placeholder } : nil,
        initial_value:,
        dispatch_action_config:,
        focus_on_load:
      }.compact
    end

    def url_input(action_id, placeholder: nil, initial_value: nil, dispatch_action_config: nil, focus_on_load: nil)
      {
        type: "url_text_input",
        action_id:,
        placeholder: placeholder ? { type: "plain_text", text: placeholder } : nil,
        initial_value:,
        dispatch_action_config:,
        focus_on_load:
      }.compact
    end

    def number_input(action_id, is_decimal_allowed:, placeholder: nil, initial_value: nil, min_value: nil,
                     max_value: nil, dispatch_action_config: nil, focus_on_load: nil)
      {
        type: "number_input",
        action_id:,
        is_decimal_allowed:,
        placeholder: placeholder ? { type: "plain_text", text: placeholder } : nil,
        initial_value:,
        min_value:,
        max_value:,
        dispatch_action_config:,
        focus_on_load:
      }.compact
    end

    def radio_buttons(action_id, options, initial_option: nil, confirm: nil, focus_on_load: nil)
      {
        type: "radio_buttons",
        action_id:,
        options:,
        initial_option:,
        confirm:,
        focus_on_load:
      }.compact
    end

    def select_menu(action_id, placeholder:, options: nil, option_groups: nil, initial_option: nil, confirm: nil,
                    focus_on_load: nil)
      {
        type: "static_select",
        action_id:,
        placeholder: { type: "plain_text", text: placeholder },
        options:,
        option_groups:,
        initial_option:,
        confirm:,
        focus_on_load:
      }.compact
    end

    def multi_select_menu(action_id, placeholder:, options: nil, option_groups: nil, initial_options: nil,
                          max_selected_items: nil, confirm: nil, focus_on_load: nil)
      {
        type: "multi_static_select",
        action_id:,
        placeholder: { type: "plain_text", text: placeholder },
        options:,
        option_groups:,
        initial_options:,
        max_selected_items:,
        confirm:,
        focus_on_load:
      }.compact
    end

    def users_select(action_id, placeholder:, initial_user: nil, confirm: nil, focus_on_load: nil)
      {
        type: "users_select",
        action_id:,
        placeholder: { type: "plain_text", text: placeholder },
        initial_user:,
        confirm:,
        focus_on_load:
      }.compact
    end

    def multi_users_select(action_id, placeholder:, initial_users: nil, max_selected_items: nil, confirm: nil,
                           focus_on_load: nil)
      {
        type: "multi_users_select",
        action_id:,
        placeholder: { type: "plain_text", text: placeholder },
        initial_users:,
        max_selected_items:,
        confirm:,
        focus_on_load:
      }.compact
    end

    def conversations_select(action_id, placeholder:, initial_conversation: nil, default_to_current_conversation: nil,
                             filter: nil, confirm: nil, focus_on_load: nil, response_url_enabled: nil)
      {
        type: "conversations_select",
        action_id:,
        placeholder: { type: "plain_text", text: placeholder },
        initial_conversation:,
        default_to_current_conversation:,
        filter:,
        confirm:,
        focus_on_load:,
        response_url_enabled:
      }.compact
    end

    def multi_conversations_select(action_id, placeholder:, initial_conversations: nil, max_selected_items: nil,
                                   default_to_current_conversation: nil, filter: nil, confirm: nil, focus_on_load: nil)
      {
        type: "multi_conversations_select",
        action_id:,
        placeholder: { type: "plain_text", text: placeholder },
        initial_conversations:,
        max_selected_items:,
        default_to_current_conversation:,
        filter:,
        confirm:,
        focus_on_load:
      }.compact
    end

    def channels_select(action_id, placeholder:, initial_channel: nil, confirm: nil, focus_on_load: nil,
                        response_url_enabled: nil)
      {
        type: "channels_select",
        action_id:,
        placeholder: { type: "plain_text", text: placeholder },
        initial_channel:,
        confirm:,
        focus_on_load:,
        response_url_enabled:
      }.compact
    end

    def multi_channels_select(action_id, placeholder:, initial_channels: nil, max_selected_items: nil, confirm: nil,
                              focus_on_load: nil)
      {
        type: "multi_channels_select",
        action_id:,
        placeholder: { type: "plain_text", text: placeholder },
        initial_channels:,
        max_selected_items:,
        confirm:,
        focus_on_load:
      }.compact
    end

    def overflow(action_id, options, confirm: nil)
      {
        type: "overflow",
        action_id:,
        options:,
        confirm:
      }.compact
    end

    def file_input(action_id, filetypes: nil, max_files: nil)
      {
        type: "file_input",
        action_id:,
        filetypes:,
        max_files:
      }.compact
    end

    def rich_text_input(action_id, placeholder: nil, initial_value: nil, dispatch_action_config: nil,
                        focus_on_load: nil)
      {
        type: "rich_text_input",
        action_id:,
        placeholder: placeholder ? { type: "plain_text", text: placeholder } : nil,
        initial_value:,
        dispatch_action_config:,
        focus_on_load:
      }.compact
    end

    def workflow_button(text, workflow:, style: nil, accessibility_label: nil)
      {
        type: "workflow_button",
        text: { type: "plain_text", text: text },
        workflow:,
        style:,
        accessibility_label:
      }.compact
    end

    def feedback_buttons(positive_text, positive_value, negative_text, negative_value, action_id: nil,
                         positive_accessibility_label: nil, negative_accessibility_label: nil)
      {
        type: "feedback_buttons",
        action_id:,
        positive_button: {
          text: { type: "plain_text", text: positive_text },
          value: positive_value,
          accessibility_label: positive_accessibility_label
        }.compact,
        negative_button: {
          text: { type: "plain_text", text: negative_text },
          value: negative_value,
          accessibility_label: negative_accessibility_label
        }.compact
      }.compact
    end

    def icon_button(icon, text, action_id, value: nil, confirm: nil, accessibility_label: nil,
                    visible_to_user_ids: nil)
      {
        type: "icon_button",
        icon:,
        text: { type: "plain_text", text: text },
        action_id:,
        value:,
        confirm:,
        accessibility_label:,
        visible_to_user_ids:
      }.compact
    end

    def option(text, value, description: nil, url: nil)
      opt = {
        text: { type: "plain_text", text: text },
        value: value
      }
      opt[:description] = { type: "plain_text", text: description } if description
      opt[:url] = url if url
      opt
    end

    def option_group(label, options)
      {
        label: { type: "plain_text", text: label },
        options: options
      }
    end

    def confirm_dialog(title:, text:, confirm:, deny:, style: nil)
      dialog = {
        title: { type: "plain_text", text: title },
        text: { type: "mrkdwn", text: text },
        confirm: { type: "plain_text", text: confirm },
        deny: { type: "plain_text", text: deny }
      }
      dialog[:style] = style if style
      dialog
    end

    def dispatch_action_config(*trigger_actions_on)
      {
        trigger_actions_on: trigger_actions_on
      }
    end

    def filter(include: nil, exclude_external_shared_channels: nil, exclude_bot_users: nil)
      f = {}
      f[:include] = include if include
      f[:exclude_external_shared_channels] = exclude_external_shared_channels if exclude_external_shared_channels
      f[:exclude_bot_users] = exclude_bot_users if exclude_bot_users
      f
    end

    def render(partial, locals: {})
      if partial.respond_to?(:to_ary)
        partial.flat_map do |item|
          render_partial_for_item(item, locals)
        end
      else
        render_partial_for_item(partial, locals)
      end
    end

    def method_missing(method, *args, **kwargs, &block)
      if @context.respond_to?(method)
        @context.public_send(method, *args, **kwargs, &block)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      @context.respond_to?(method, include_private) || super
    end

    private

    def render_partial_for_item(item, locals)
      partial_name = item.class.name.underscore
      partial_path = "#{partial_name.pluralize}/#{partial_name}"

      result = @context.render(
        partial: partial_path,
        locals: locals.merge(partial_name.to_sym => item),
        formats: [:slack_blocks]
      )

      JSON.parse(result)["blocks"] || []
    end
  end
end
