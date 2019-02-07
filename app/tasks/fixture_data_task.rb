# frozen_string_literal: true

class FixtureDataTask
  include HashieCreatable

  FIXTURES_DIR = './db/fixtures'
  LISTS_DIR = "#{FIXTURES_DIR}/lists"
  SEASON_LIST_PATH = "#{LISTS_DIR}/season_list.yml"
  UPDATED_TO_NOT_WATCHABLE_LIST_PATH = "#{LISTS_DIR}/updated_to_not_watchable_list.yml"
  SEASONS_DIR = "#{FIXTURES_DIR}/seasons"
  SEASONS_PATH = "#{SEASONS_DIR}/*.yml"

  class << self
    def execute(task_name)
      Rake::Task["data:fixtures:#{task_name}"].execute
    end

    def update_not_watchable_seasons
      initialize_dir(FixtureDataTask::SEASONS_DIR)
      logger.debug('selecting seasons now...')
      target_seasons = SeasonHash.already_created.reject(&:watchable)
      target_seasons.each { |target_season| create_season(target_season) }
    end

    def create_season_list(target_path = FixtureDataTask::SEASON_LIST_PATH)
      initialize_dir(FixtureDataTask::LISTS_DIR)
      initialize_yaml(target_path)
      season_list = Scraping::SeasonLineup.execute(YAMLFile.open(target_path))
      YAMLFile.write(target_path, season_list)
    end

    def create_uncreated_seasons
      initialize_dir(FixtureDataTask::SEASONS_DIR)
      logger.debug('selecting seasons now...')
      season_list = YAMLFile.open(FixtureDataTask::SEASON_LIST_PATH)
      already_created_season_titles = SeasonHash.already_created.map(&:title)
      target_season_titles =
        season_list
          .map(&:title)
          .reject { |season_title| already_created_season_titles.include?(season_title) }
      target_season_titles.each { |season_title| create_season(initialize_season(season_title)) }
    end

    def create_designated_season(title)
      logger.debug('selecting seasons now...')
      create_season(initialize_season(title)) unless SeasonHash.already_created.any? { |season| season.title == title }
    end

    def update_designated_seasons(target_string)
      initialize_dir(FixtureDataTask::SEASONS_DIR)
      logger.debug('selecting seasons now...')
      target_seasons =
        SeasonHash.already_created.select { |season| season.title =~ %r(#{Regexp.escape(target_string)}) }
      target_seasons.each { |target_season| create_season(target_season) }
    end

    def update_on_air_seasons
      initialize_dir(FixtureDataTask::SEASONS_DIR)
      logger.debug('selecting seasons now...')
      target_seasons = SeasonHash.already_created.select(&:on_air?)
      target_seasons.each { |target_season| create_season(target_season) }
    end

    def update_to_not_watchable
      logger.debug('selecting seasons now...')
      updated_season_titles = YAMLFile.open(FixtureDataTask::UPDATED_TO_NOT_WATCHABLE_LIST_PATH)
      target_seasons = SeasonHash.already_created.select { |season| updated_season_titles.include?(season.title) }
      target_seasons.each { |target_season| update_watchable(target_season) }
    end

    def update_tags
      initialize_dir(FixtureDataTask::SEASONS_DIR)
      logger.debug('selecting seasons now...')
      target_seasons = SeasonHash.already_created.select(&:watchable)
      target_seasons.each { |target_season| create_season(target_season, %i(tags)) }
    end

    private

    def initialize_dir(target_path)
      FileUtils.mkpath(target_path) unless Dir.exist?(target_path)
    end

    def initialize_yaml(target_path, value = [])
      YAMLFile.write(target_path, value) unless File.exist?(target_path)
    end

    def initialize_season(title)
      SeasonHash.new(title: title)
    end

    def create_season(season, targets = %i(tags related_seasons others))
      start_log(season.title)
      season = Scraping::DanimeHeadStore.execute(season, targets)
      season = Api::NicoContentsSearch.add_episode_info(season) if targets.include?(:others)
      season.watchable = false unless season.episodes.all? { |episode| episode.has_key?(:description) }
      path = season.delete(:file_path)
      target_path = path ? path : new_season_path
      YAMLFile.write(target_path, season)
      finish_log(season.title)
    end

    def new_season_path
      "#{FixtureDataTask::SEASONS_DIR}/season_#{next_season_no}.yml"
    end

    def next_season_no
      format('%05d', Dir.glob(FixtureDataTask::SEASONS_PATH).map { |path| pick_up_season_no(path) }.max + 1)
    end

    def pick_up_season_no(path)
      path.split('/').last.slice(%r(\d+)).to_i
    end

    def update_watchable(season, watchable: false)
      start_log(season.title)
      season.watchable = watchable
      path = season.delete(:file_path)
      YAMLFile.write(path, season)
      finish_log(season.title)
    end
  end
end
