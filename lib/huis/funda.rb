# frozen_string_literal: true

require "oga"
require "http"

module Huis
  class Funda
    def self.start
      new.tap(&:sign_in)
    end

    def initialize(client: nil)
      @client = client
    end

    def saved_houses
      html = Oga.parse_html(client.html)
      html.css(".search-result").map { |res|
        title = res.at_css(".search-result__header-title-col")
        { address: title.text.gsub(/\s+/, " ").strip, url: title.at_css("a")[:href] }
      }
    end

    def sign_in
      client.visit("https://www.funda.nl/en/")
      client.click_on("Log in")
      sleep 2
      client.fill_in("Email address", with: ENV["FUNDA_EMAIL"])
      client.fill_in("Password", with: ENV["FUNDA_PASSWORD"])
      client.click_button("Log In")
      client.assert_title("Saved houses [funda]")
    end

    def client
      @client ||= Clients.browser
    end
  end
end
