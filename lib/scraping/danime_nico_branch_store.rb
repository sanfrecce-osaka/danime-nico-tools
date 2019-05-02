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
          different_title: season.different_title.freeze
        )
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

    class << self
      def find_season_including_nonexistent_episodes(season)
        Scraping::DanimeNicoBranchStore::SEASONS_INCLUDING_NONEXISTENT_EPISODES
          .find { |season_including_nonexistent_episode| season_including_nonexistent_episode == season }
      end

      def find_season_including_different_title_episode(season)
        Scraping::DanimeNicoBranchStore::SEASONS_INCLUDING_DIFFERENT_TITLE_EPISODES
          .find { |season_including_different_title_episode| season_including_different_title_episode == season }
      end

      def find_season_with_different_title(season)
        Scraping::DanimeNicoBranchStore::SEASONS_WITH_DIFFERENT_TITLE
          .find { |season_with_different_title| season_with_different_title == season }
      end
    end
  end
end
