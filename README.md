# Slocks

**Slocks** is a DSL & a Rails template handler for generating Slack [Block Kit](https://docs.slack.dev/block-kit/) surfaces.

No implied warranty. Solid chance it won't work.

## Why Slocks?
I've lost too many hours of my life to 
\*write\*→\*⌘C\*→\*⌘-Tab to Block Kit Builder\*→\*⌘V\*→"dammit"→\*⌘-Tab\*→\*rewrite\*→\*repeat\*.

No more.
## Installation

Add to your Gemfile:

```ruby
gem 'slocks'
```

Then run:

```bash
bundle install
```

## Quick Start

Create a template.

```ruby
# app/views/notifications/order_shipped.slack_blocks

header "📦 Your order has shipped!"

section "*Order ##{@order.id}* is on its way", markdown: true

divider

section "Tracking:",
        fields: [
          mrkdwn_text("*Carrier:* #{@order.carrier}"),
          mrkdwn_text("*Tracking:* `#{@order.tracking_number}`")
        ]

actions [ button("Track Package", "track_#{@order.id}", style: "primary", url: @order.tracking_url) ]
```

Render it in your controller or service:

```ruby
class OrdersController < ApplicationController
  def mark
    @user = current_user
    
    payload = render_to_string(
      template: 'notifications/welcome',
      formats: [:slack_message]
    )
    
    slack_client.chat_postMessage(
      channel: @user.slack_id,
      **JSON.parse(payload)
    )
  end
end
```

## Blocks Reference

### Layout Blocks

#### Header
```ruby
header "🎉 Great news, Baltimore!"
```

#### Section
```ruby
# simple text
section "hello world"

# mrkdwn text
section "to *bold*ly _italic_ize...", markdown: true

# fields
section "details:",
  fields: [
    mrkdwn_text("*computer:* over"),
    mrkdwn_text("*virus:* VERY yes.")
  ]

# accessorizing a little (images, buttons, etc)
section "click to continue",
  accessory: button("click me, i dare you", "explode_action")
```

#### Divider
```ruby
divider
```

#### Context
```ruby
context [
  mrkdwn_text("Last updated: #{time_ago_in_words(@updated_at)} ago"),
  image_element("https://crouton.net/crouton.png", "icon")
]
```

#### Actions
(some these won't do anything unless you use them somewhere expecting accessories! it'd do you a lot of good to read Slack's Block Kit docs before you try anything...)

```ruby
actions [
  button("Approve", "approve", style: "primary"),
  button("Reject", "reject", style: "danger"),
  button("More Info", "info")
]
```

#### Image
```ruby
image "https://example.com/photo.jpg", "Photo description",
  title: "Amazing Photo"
```

#### Input
```ruby
input "Your name",
  plain_text_input("name_input", placeholder: "Enter your name")

input "Choose an option",
  select_menu("option_select",
    placeholder: "Select one",
    options: [
      option("Option 1", "opt1"),
      option("Option 2", "opt2")
    ]
  )
```

#### File
```ruby
file "F123ABC456", source: "remote"
```

#### Video
```ruby
video "How to use Slocks",
  "https://example.com/video",
  "https://example.com/thumbnail.jpg",
  "https://example.com/video.mp4",
  alt_text: "Tutorial video"
```

### Block Elements

#### Buttons
```ruby
button("Click me", "action_id")
button("Primary", "action", style: "primary")
button("Danger", "delete", style: "danger")
button("Link", "link", url: "https://example.com")
```

#### Select Menus
```ruby
# Static select
select_menu("action_id",
  placeholder: "Choose one",
  options: [
    option("Label 1", "value1"),
    option("Label 2", "value2")
  ]
)

# Multi-select
multi_select_menu("action_id",
  placeholder: "Choose multiple",
  options: [...]
)

# User select
users_select("user_action", placeholder: "Select a user")

# Channel select
channels_select("channel_action", placeholder: "Select a channel")

# Conversation select
conversations_select("convo_action", placeholder: "Select a conversation")
```

#### Inputs
```ruby
# Text input
plain_text_input("action_id",
  placeholder: "Type here...",
  multiline: true
)

# Email input
email_input("email_action", placeholder: "your@email.com")

# URL input
url_input("url_action", placeholder: "https://...")

# Number input
number_input("number_action",
  is_decimal_allowed: true,
  min_value: 0,
  max_value: 100
)
```

#### Date & Time Pickers
```ruby
date_picker("date_action", placeholder: "Select a date")
time_picker("time_action", placeholder: "Select a time")
datetime_picker("datetime_action")
```

#### Other Elements
```ruby
# Checkboxes
checkboxes("check_action", [
  option("Option 1", "val1"),
  option("Option 2", "val2")
])

# Radio buttons
radio_buttons("radio_action", [
  option("Choice 1", "c1"),
  option("Choice 2", "c2")
])

# Overflow menu
overflow("overflow_action", [
  option("Edit", "edit"),
  option("Delete", "delete")
])

# File input
file_input("file_action", filetypes: ["pdf", "doc"], max_files: 5)
```

### Composition Objects

#### Text Objects
```ruby
mrkdwn_text("*Bold* and _italic_")
plain_text("Plain text", emoji: true)
```

#### Option & Option Groups
```ruby
option("Display text", "value")
option("With description", "val", description: "More details")

option_group("Group label", [
  option("Opt 1", "v1"),
  option("Opt 2", "v2")
])
```

#### Confirm Dialog
```ruby
confirm_dialog(
  title: "Are you sure?",
  text: "This action cannot be undone",
  confirm: "Yes, delete it",
  deny: "Cancel",
  style: "danger"
)
```

## Modals

Create a modal template at `app/views/modals/feedback.slack_modal`:

```ruby
title "Send Feedback"
submit "Submit"
close "Cancel"
callback "feedback_modal"

section "How was your experience?", markdown: true

input "Rating",
  select_menu("rating",
    placeholder: "Choose rating",
    options: [
      option("⭐⭐⭐⭐⭐ Excellent", "5"),
      option("⭐⭐⭐⭐ Good", "4"),
      option("⭐⭐⭐ Okay", "3"),
      option("⭐⭐ Poor", "2"),
      option("⭐ Bad", "1")
    ]
  )

input "Comments",
  plain_text_input("comments",
    placeholder: "Tell us more...",
    multiline: true
  ),
  optional: true
```

Render it:

```ruby
modal_json = render_to_string(
  template: 'modals/feedback',
  formats: [:slack_modal]
)

slack_client.views_open(
  trigger_id: params[:trigger_id],
  view: JSON.parse(modal_json)
)
```

## Rails Helpers

All Rails helpers work in templates:

```ruby
section "Order summary:",
  fields: [
    mrkdwn_text("*Items:* #{pluralize(@order.items.count, 'item')}"),
    mrkdwn_text("*Total:* #{number_to_currency(@order.total)}"),
    mrkdwn_text("*Ordered:* #{time_ago_in_words(@order.created_at)} ago")
  ]
```

## Partials

Render partials just like ERB:

```ruby
# app/views/orders/_order.slack_blocks
section "*Order ##{@order.id}*",
  fields: [
    mrkdwn_text("*Status:* #{@order.status}"),
    mrkdwn_text("*Total:* #{number_to_currency(@order.total)}")
  ]

# app/views/orders/summary.slack_blocks
header "Your Orders"

render @orders  # Renders _order.slack_blocks for each order
```

## Rich Text (Advanced)

For rich text blocks with complex formatting:

```ruby
rich_text do
  section do
    text "Hello ", bold: true
    text "world!", italic: true
    emoji "wave"
    link "https://example.com", text: "Click here"
  end
  
  list(style: "bullet") do
    text "First item"
    text "Second item"
  end
end
```

## Contributing

Bug reports are welcome, but pull requests are much _much_ welcomer.

This repo lives on GitHub at https://github.com/24c02/slocks. Happy hacking!
## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

built with <3️ by nora and various LLM-slop providers.

heavily inspired by Akira Matsuda's fantastic [JB](https://github.com/amatsuda/jb/) gem.