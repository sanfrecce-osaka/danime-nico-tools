# frozen_string_literal: true

module Scraping
  class DanimeNicoBranchStore < Base
    class << self
      private

      def initialize_season_including_nonexistent_episodes(season)
        SeasonHash.new(
          title: season.title.freeze,
          episodes: season.episodes.map do |episode|
            EpisodeHash.new(
              episode_no: episode.episode_no.freeze,
              title: episode.title.freeze
            ).freeze
          end.freeze
        ).freeze
      end

      def initialize_season_including_different_title_episodes(season)
        SeasonHash.new(
          title: season.title.freeze,
          episodes: season.episodes.map do |episode|
            hashie(
              head: EpisodeHash.new(
                episode_no: episode.head.episode_no.freeze,
                title: episode.head.title.freeze
              ).freeze,
              nico_branch: EpisodeHash.new(
                episode_no: episode.nico_branch.episode_no.freeze,
                title: episode.nico_branch.title.freeze
              ).freeze
            )
          end.freeze
        ).freeze
      end

      def initialize_season_with_different_title(season)
        SeasonHash.new(
          title: season.title.freeze,
          differences: hashie(
            titles: hashie(
              lineup: season.different_titles.lineup.freeze,
              episode: season.different_titles.episode.freeze
            ).freeze
          ).freeze
        ).freeze
      end
    end

    SEASONS_INCLUDING_NONEXISTENT_EPISODES =
      Settings.seasons_including_nonexistent_episodes.map do |season|
        initialize_season_including_nonexistent_episodes(season)
      end.freeze

    SEASONS_INCLUDING_DIFFERENT_TITLE_EPISODES =
      Settings.seasons_including_different_title_episodes.map do |season|
        initialize_season_including_different_title_episodes(season)
      end.freeze

    SEASONS_WITH_DIFFERENT_TITLE =
      Settings.seasons_with_different_title.map do |season|
        initialize_season_with_different_title(season)
      end.freeze
  end
end
