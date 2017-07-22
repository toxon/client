# frozen_string_literal: true

module Widgets
  class Chat
    attr_reader :focused

    def initialize(x, y, width, height)
      @focused = false

      info_height    = 4
      message_height = 1
      history_height = height - info_height - message_height

      info_top    = 0
      history_top = info_height
      message_top = info_height + history_height

      @info    = Info.new       x, y + info_top,    width, info_height
      @history = History.new    x, y + history_top, width, history_height
      @message = NewMessage.new x, y + message_top, width, message_height
    end

    def render
      @info.render
      @history.render
      @message.render
    end

    def trigger(event)
      case event
      when Events::Panel::Base
        @history.trigger event
      when Events::Text::Base
        @message.trigger event
      end
    end

    def focused=(value)
      @focused = !!value
      @info.focused    = focused
      @history.focused = focused
      @message.focused = focused
    end
  end
end
