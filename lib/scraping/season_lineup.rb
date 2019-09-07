# frozen_string_literal: true

module Scraping
  class SeasonLineup < Base
    include Loggable

    SEASON_LINEUP_URL = 'http://site.nicovideo.jp/danime/all_contents_1201.html'

    class << self
      def execute(old_season_list)
        initialize_headless_driver
        @driver.get(Scraping::SeasonLineup::SEASON_LINEUP_URL)
        readboxes = @driver.find_elements(:class, 'readbox')
        new_season_list = readboxes.map.with_index(1) do |readbox, index|
          logger.debug("getting links now... #{index}/#{readboxes.length}")
          readbox
            .find_elements(:tag_name, 'a')
            .map { |link| hashie(title: title_on_head(link.text.strip), first_episode_url: link.attribute('href')) }
        end.flatten
        registered_titles = old_season_list.map(&:title)
        old_season_list.push(new_season_list.reject { |season| registered_titles.include?(season.title) }).flatten
      ensure
        @driver.quit
      end

      private

      def title_on_head(link)
        Scraping::DanimeNicoBranchStore::SEASONS_WITH_DIFFERENT_TITLE
          .find { |season| season.differences.titles.lineup == link }&.title.presence || link
      end
    end
  end
end
