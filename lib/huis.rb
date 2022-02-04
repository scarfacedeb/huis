# frozen_string_literal: true

require "huis/walter"
require "huis/funda"
require "huis/bot"
require "huis/server"

module Huis
  def self.walter
    @walter ||= Walter.start
  end

  def self.start_bot
    Bot.start
  end

  def self.start_server
    Server.start
  end
end
