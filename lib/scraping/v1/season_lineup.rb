# frozen_string_literal: true

module Scraping
  module V1
    class SeasonLineup < Base
      include Loggable

      SEASON_LINEUP_URL = 'http://site.nicovideo.jp/danime/all_contents_1201.html'

      class << self
        def execute(old_season_list)
          initialize_headless_driver
          @driver.get(SEASON_LINEUP_URL)
          readboxes = @driver.find_elements(:class, 'readbox')
          new_season_list = readboxes.map.with_index(1) do |readbox, index|
            logger.debug("getting links now... #{index}/#{readboxes.length}")
            readbox
              .find_elements(:tag_name, 'a')
              .map { |link| hashie(title: link.text.strip, first_episode_url: link.attribute('href')) }
          end.flatten
          old_season_list.push(new_season_list.reject { |season| old_season_list.include?(season) }).flatten
        ensure
          @driver.quit
        end
      end
    end
  end
end
