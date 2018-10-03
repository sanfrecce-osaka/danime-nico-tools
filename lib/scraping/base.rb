# frozen_string_literal: true

module Scraping
  class Base
    include HashieCreatable

    class_attribute :driver

    class << self
      def initialize_headless_driver
        options = Selenium::WebDriver::Chrome::Options.new
        options.add_argument('--headless')
        options.add_argument('--disable-dev-shm-usage') if Rails.env.production?
        options.binary = ENV.fetch('GOOGLE_CHROME_SHIM', nil)
        @driver = Selenium::WebDriver.for :chrome, options: options
      end
    end
  end
end
