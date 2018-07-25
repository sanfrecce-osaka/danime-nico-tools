# frozen_string_literal: true

module Scraping
  class Base
    include HashieCreatable

    class_attribute :driver

    class << self
      def initialize_headless_driver
        options = Selenium::WebDriver::Chrome::Options.new
        options.add_argument('--headless')
        @driver = Selenium::WebDriver.for :chrome, options: options
      end
    end
  end
end
