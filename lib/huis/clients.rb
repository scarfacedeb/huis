# frozen_string_literal: true

require "capybara"

module Huis
  module Clients
    module_function

    def browser(headless: true, download_path: "~/tmp/huis/")
      Capybara::Session.new(headless ? :selenium_chrome_headless : :selenium_chrome).tap do |session|
        session.driver.browser.download_path = create_download_path(download_path)
      end
    end

    def create_download_path(path)
      path = File.expand_path(path)
      FileUtils.mkdir_p(path) unless File.exist?(path)
      path
    end
  end
end
