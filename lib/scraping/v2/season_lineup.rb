# frozen_string_literal: true

module Scraping
  module V2
    class SeasonLineup < Base
      include Loggable

      SEASON_LINEUP_URL = 'http://site.nicovideo.jp/danime/all_contents_1201.html'.freeze

      class << self
        def execute(old_season_list)
          new(old_season_list).send(:create_new_season_list)
        end
      end

      private

      def initialize(old_season_list)
        @old_season_list = old_season_list
      end

      def create_new_season_list
        @old_season_list | nico_season_list
      end

      def nico_season_list
        get(SEASON_LINEUP_URL).search('.readbox a').map(&create_season)
      end

      def get(url)
        Mechanize.new.get(url).tap(&replace_non_escaped_lt_and_gt)
      end

      def replace_non_escaped_lt_and_gt
        -> (page) { page.body.force_encoding('UTF-8').gsub!(%r((<a.*?>.*?)<(.*?)>(.*</a>))) { '$1&lt;$2&gt;$3' } }
      end

      def create_season
        -> (link) { hashie(title: title_on_head(link.inner_text.trim), first_episode_url: link[:href]) }
      end

      def title_on_head(title_on_nico)
        Scraping::DanimeNicoBranchStore.find_season_having_different_title(title_on_nico)&.title.presence ||
          title_on_nico
      end
    end
  end
end
