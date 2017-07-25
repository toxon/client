# frozen_string_literal: true

require 'thread'

require 'faker'

require 'screen'

class Main
  def self.inherited(_base)
    raise "#{self} is final"
  end

  def self.mutex
    (@mutex ||= Mutex.new).tap { freeze }
  end

  def initialize
    raise "#{self.class} is singleton" unless self.class.mutex.try_lock
    call
  end

private

  def call
    before_loop
    loop do
      before_iteration
      sleep
      after_iteration
    end
    after_loop
  end

  def sleep
    super 0.01
  end

  def before_loop
    @screen = Screen.new
    Style.default = Style.new
  end

  def after_loop
    @screen.close
  end

  def before_iteration
    @screen.props = state
    @screen.render
  end

  def after_iteration
    @screen.poll
  end

  def state
    @state ||= {
      x: 0,
      y: 0,
      width: Curses.stdscr.maxx,
      height: Curses.stdscr.maxy,
      focus: :sidebar,
      focused: true,

      on_window_left: method(:on_window_left),
      on_window_right: method(:on_window_right),

      sidebar: {
        x: 0,
        y: 0,
        width: Widgets::Logo::WIDTH,
        height: Curses.stdscr.maxy,
        focus: :menu,
        focused: true,

        logo: {
          x: 0,
          y: 0,
          width: Widgets::Logo::WIDTH,
          height: Widgets::Logo::HEIGHT,
        }.freeze,

        menu: {
          x: 0,
          y: Widgets::Logo::HEIGHT,
          width: Widgets::Logo::WIDTH,
          height: Curses.stdscr.maxy - Widgets::Logo::HEIGHT,
          focused: true,

          active: 0,
          top: 0,
          items: 1.upto(Curses.stdscr.maxy).map do
            {
              name: Faker::Name.name,
              online: [false, true].sample,
            }
          end,
        }.freeze,
      }.freeze,

      chat: {
        x: Widgets::Logo::WIDTH,
        y: 0,
        width: Curses.stdscr.maxx - Widgets::Logo::WIDTH,
        height: Curses.stdscr.maxy,
        focus: :new_message,
        focused: false,

        info: {
          x: Widgets::Logo::WIDTH,
          y: 0,
          width: Curses.stdscr.maxx - Widgets::Logo::WIDTH,
          height: 2,
          focused: false,

          name: Faker::Name.name,
          public_key: SecureRandom.hex(32),
        }.freeze,

        new_message: {
          x: Widgets::Logo::WIDTH,
          y: Curses.stdscr.maxy - 1,
          width: Curses.stdscr.maxx - Widgets::Logo::WIDTH,
          height: 1,
          focused: false,

          text: '',
          cursor_pos: 0,
        }.freeze,

        history: {
          x: Widgets::Logo::WIDTH,
          y: 2,
          width: Curses.stdscr.maxx - Widgets::Logo::WIDTH,
          height: Curses.stdscr.maxy - 3,
          focused: true,

          messages: 1.upto(100).map do
            {
              out: rand <= 0.2,
              time: Faker::Time.forward,
              name: Faker::Name.name,
              text: Faker::Lorem.sentence,
            }
          end,
        }.freeze,
      }.freeze,
    }.freeze
  end

  def on_window_left
    @state = state.merge(
      focus: :sidebar,

      sidebar: state[:sidebar].merge(
        focused: true,

        logo: state[:sidebar][:logo].merge(focused: state[:sidebar][:focus] == :logo).freeze,
        menu: state[:sidebar][:menu].merge(focused: state[:sidebar][:focus] == :menu).freeze,
      ).freeze,

      chat: state[:chat].merge(
        focused: false,

        info:               state[:chat][:info].merge(focused: false).freeze,
        new_message: state[:chat][:new_message].merge(focused: false).freeze,
        history:         state[:chat][:history].merge(focused: false).freeze,
      ).freeze,
    ).freeze
  end

  def on_window_right
    @state = state.merge(
      focus: :sidebar,

      sidebar: state[:sidebar].merge(
        focused: true,

        logo: state[:sidebar][:logo].merge(focused: false).freeze,
        menu: state[:sidebar][:menu].merge(focused: false).freeze,
      ).freeze,

      chat: state[:chat].merge(
        focused: false,

        info:               state[:chat][:info].merge(focused: state[:chat][:focus] == :info).freeze,
        new_message: state[:chat][:new_message].merge(focused: state[:chat][:focus] == :new_message).freeze,
        history:         state[:chat][:history].merge(focused: state[:chat][:focus] == :history).freeze,
      ).freeze,
    ).freeze
  end
end
