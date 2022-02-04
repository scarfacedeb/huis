# frozen_string_literal: true

require "json"
require "oga"
require "http"
require "huis/clients"

module Huis
  class Walter
    BASE_URL = "https://app.walterliving.com/"

    attr_writer :cookies, :csrf_token

    def self.start
      new.tap(&:sign_in)
    end

    def initialize(client: nil)
      @client = client
    end

    def search(query)
      address_id = api_search(query).dig("addresses", 0, "address_object_id")
      create_report(address_id)

      url = client.current_url
      download_pdf

      {
        report_url: url.sub(/start$/, ""),
        pdf_url: url.sub(".com/report-plus", ".com/pdf/report-plus").sub(/start$/, "en")
      }
    rescue StandardError => e
      { error: e.message }
    end

    def api_search(query)
      headers = { "x-csrf-token": csrf_token, cookie: cookies }
      json = { query: query, city: "" }
      response = HTTP.headers(headers).post("#{BASE_URL}address-search", json: json)
      JSON.parse(response)
    end

    def create_report(address_id)
      client.visit("#{BASE_URL}dossier/create/#{address_id}/start")
      client.click_on("Next")
      sleep 5
      client.click_on("View valuation report")
    end

    def download_pdf
      client.click_on("Download PDF")
    end

    #     def search2(address = "Balistraat 54, 2315 BW, Leiden")
    #       client.execute_script("document.querySelector('.popout-sheet__input').click()")
    #       client.fill_in("Search for address", with: address)
    #       sleep 2
    #       client.execute_script("document.querySelector('.menu__item').click()")
    #       sleep 2
    #     end

    def signed_in?
      @signed_in
    end

    def sign_in
      client.visit("#{BASE_URL}login?return_to=https%3A%2F%2Fapp.walterliving.com%2F")
      client.fill_in("email", with: ENV["WALTER_EMAIL"])
      client.fill_in("password", with: ENV["WALTER_PASSWORD"])
      client.click_button("Log In")
      client.assert_title("Your homes | Walter Living")

      @signed_in = true
    end

    def client
      @client ||= Clients.browser
    end

    def cookies
      @cookies ||= client.driver.browser.manage.all_cookies
        .map { [_1[:name], _1[:value]] }
        .select { |k, _| k =~ /walter/ }
        .map { _1.join("=") }
        .join("; ")
    end

    def csrf_token
      @csrf_token ||= Oga.parse_html(client.html).at_css('meta[name="csrf-token"]').send(:[], :content)
    end
  end
end
