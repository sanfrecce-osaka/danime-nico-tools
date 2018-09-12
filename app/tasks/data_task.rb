# frozen_string_literal: true

class DataTask
  include HashieCreatable

  FIXTURES_DIR = "./db/fixtures"
  LISTS_DIR = "#{FIXTURES_DIR}/lists"
  SEASON_LIST_PATH = "#{LISTS_DIR}/season_list.yml"
  SEASONS_DIR = "#{FIXTURES_DIR}/seasons"
  SEASONS_PATH = "#{SEASONS_DIR}/*.yml"

  class << self
    def get_not_watchable_season_list
      puts already_created_seasons.reject(&:watchable).map(&:title)
    end

    def create_season_list(target_path = DataTask::SEASON_LIST_PATH)
      initialize_dir(DataTask::LISTS_DIR)
      initialize_yaml(target_path)
      season_list = Scraping::SeasonLineup.execute(YAMLFile.open(target_path))
      YAMLFile.write(target_path, season_list)
    end

    def create_uncreated_seasons
      initialize_dir(DataTask::SEASONS_DIR)
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
      initialize_dir(DataTask::SEASONS_DIR)
      logger.debug('selecting seasons now...')
      target_seasons =
        already_created_seasons.select { |season| season.title =~ %r(#{Regexp.escape(target_string)}) }
      target_seasons.each { |target_season| create_season(target_season) }
    end

    def update_on_air_seasons
      initialize_dir(DataTask::SEASONS_DIR)
      logger.debug('selecting seasons now...')
      target_seasons = already_created_seasons.select(&:watchable).select { |season| on_air_season?(season) }
      target_seasons.each { |target_season| create_season(target_season) }
    end

    private

    def already_created_seasons
      Dir.glob(DataTask::SEASONS_PATH).map { |path| YAMLFile.open(path).merge(file_path: path) }
    end

    def initialize_dir(target_path)
      FileUtils.mkpath(target_path) unless Dir.exist?(target_path)
    end

    def initialize_yaml(target_path, value = [])
      YAMLFile.write(target_path, value) unless File.exist?(target_path)
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
      "#{DataTask::SEASONS_DIR}/season_#{next_season_no}.yml"
    end

    def next_season_no
      format('%05d', Dir.glob(DataTask::SEASONS_PATH).length + 1)
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
