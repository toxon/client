# frozen_string_literal: true

module Curses
  using Helpers

  module React
    module Nodes
      class Text
        attr_reader :x, :max_width

        def initialize(element, window, x:, max_width:)
          @element = element
          @window = window
          self.x = x
          self.max_width = max_width
        end

        def props
          @element.all_props
        end

        def width
          [props[:text].length, max_width].min
        end

        def draw
          return if props[:text].nil?
          @window.attron props[:attr] if props[:attr]
          setpos x, props[:y]
          addstr props[:text].ljustetc width
          @window.attroff props[:attr] if props[:attr]
        end

        def setpos(x, y)
          @window.setpos y, x
        end

        def addstr(s)
          @window.addstr s
        end

      private

        def x=(value)
          raise TypeError,     "expected x to be an #{Integer}"                 unless value.is_a? Integer
          raise ArgumentError, 'expected x to be greater than or equal to zero' unless value >= 0
          @x = value
        end

        def max_width=(value)
          raise TypeError, "expected max width to be an #{Integer}" unless value.is_a? Integer
          @max_width = value
        end
      end
    end
  end
end
