# frozen_string_literal: true

module Widgets
  class Chat < VPanel
    def initialize(_parent)
      super

      @info    = Info.new       self
      @history = History.new    self
      @message = NewMessage.new self
    end

    def props=(_value)
      super

      @info.props    = props[:info]
      @history.props = props[:history]

      @message.props = props[:new_message].merge(
        on_putc: props[:on_new_message_putc],

        on_left:  props[:on_new_message_left],
        on_right: props[:on_new_message_right],
        on_home:  props[:on_new_message_home],
        on_end:   props[:on_new_message_end],

        on_backspace: props[:on_new_message_backspace],
        on_delete:    props[:on_new_message_delete],
      ).freeze
    end

    def trigger(event)
      focus&.trigger event
    end

  private

    def focus
      case props[:focus]
      when :info        then @info
      when :history     then @history
      when :new_message then @message
      end
    end

    def children
      [@info, @history, @message]
    end
  end
end
