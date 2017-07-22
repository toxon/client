# frozen_string_literal: true

module Widgets
  class Window < Container
    def initialize(x, y, width, height)
      super

      @menu = Widgets::Menu.new 0, 0, nil, height

      @messenger = Widgets::Messenger.new 0, 0, width - @menu.width, height

      self.focus = @messenger

      @menu_visible = false
    end

    def children
      focus == @menu ? [@messenger, @menu] : [@messenger]
    end

    def trigger(event)
      case event
      when Events::Tab
        self.focus = focus == @menu ? @messenger : @menu
      else
        focus.trigger event
      end
    end
  end
end