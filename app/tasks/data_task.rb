# frozen_string_literal: true

class DataTask
  include HashieCreatable

  OUTPUT_ROOT_DIR = './db'
  SEASON_LIST_PATH = "#{OUTPUT_ROOT_DIR}/season_list.yml"
  OUTPUT_SEASONS_DIR = "#{OUTPUT_ROOT_DIR}/data"
  OUTPUT_SEASONS_PATH = "#{OUTPUT_SEASONS_DIR}/*.yml"

  class << self
    def get_not_watchable_season_list
      puts already_created_seasons.reject(&:watchable).map(&:title)
    end

    def create_season_list
      YAMLFile.write(DataTask::SEASON_LIST_PATH, []) unless File.exist?(DataTask::SEASON_LIST_PATH)
      season_list = Scraping::SeasonLineup.execute(YAMLFile.open(DataTask::SEASON_LIST_PATH))
      YAMLFile.write(DataTask::SEASON_LIST_PATH, season_list)
    end

    def create_uncreated_seasons
      logger.debug('selecting seasons now...')
      season_list = YAMLFile.open(DataTask::SEASON_LIST_PATH)
      already_created_season_titles = already_created_seasons.map(&:title)
      target_season_titles =
        season_list
          .map(&:title)
          .reject { |season_title| already_created_season_titles.include?(season_title) }
      target_season_titles.each { |season_title| create_season(initialize_season(season_title)) }
    end

    def create_designated_season(title)
      logger.debug('selecting seasons now...')
      create_season(initialize_season(title)) unless already_created_seasons.any? { |season| season.title == title }
    end

    def update_designated_seasons(target_string)
      logger.debug('selecting seasons now...')
      target_seasons =
        already_created_seasons.select { |season| season.title =~ %r(#{Regexp.escape(target_string)}) }
      target_seasons.each { |target_season| create_season(target_season) }
    end

    def update_on_air_seasons
      logger.debug('selecting seasons now...')
      target_seasons = already_created_seasons.select(&:watchable).select { |season| on_air_season?(season) }
      target_seasons.each { |target_season| create_season(target_season) }
    end

    private

    def already_created_seasons
      Dir.glob(DataTask::OUTPUT_SEASONS_PATH).map { |path| YAMLFile.open(path).merge(file_path: path) }
    end

    def initialize_season(title)
      SeasonHash.new(title: title)
    end

    def create_season(season)
      start_log(season.title)
      season = Scraping::DanimeHeadStore.execute(season)
      season = Api::NicoContentsSearch.add_episode_info(season)
      path = season.delete(:file_path)
      target_path = path ? path : new_season_path
      YAMLFile.write(target_path, season)
      finish_log(season.title)
    end

    def new_season_path
      "#{DataTask::OUTPUT_SEASONS_DIR}/season_#{next_season_no}.yml"
    end

    def next_season_no
      format('%05d', Dir.glob(DataTask::OUTPUT_SEASONS_PATH).length + 1)
    end

    def on_air_season?(season)
      next_episode_content_ids =
        season.episodes
          .map { |episode| episode.description.match(%r(次話→((so\d+)|[[:blank:]]|$))) }
          .reject(&:nil?)
          .map { |match_data| match_data[1] }
      (next_episode_content_ids - season.episodes.map(&:content_id)).length > 0
    end
  end
end
