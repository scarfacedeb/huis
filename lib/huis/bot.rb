# frozen_string_literal: true

require "telegram/bot"

module Huis
  module Bot
    def self.start
      Telegram::Bot::Client.run(ENV["BOT_TOKEN"]) do |bot|
        puts "=== Telegram bot start ==="

        bot.listen do |message|
          case message.text
          when /report /
            query = message.text.match(/report (.*)/) { |m| m[1] }.gsub(/\s+/, " ").strip
            response = Huis.walter.search(query)

            text =
              if response[:error]
                "ERROR: #{response[:error]}"
              else
                "Walter: #{response[:report_url]}. PDF: #{response[:pdf_url]}."
              end

            bot.api.send_message(chat_id: message.chat.id, text: text)
          end
        end
      end
    end
  end
end
