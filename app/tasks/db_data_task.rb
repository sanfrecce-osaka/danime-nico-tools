# frozen_string_literal: true

class DBDataTask
  include HashieCreatable

  class << self
    def execute(task_name)
      Rake::Task["data:db:#{task_name}"].execute
    end

    def create_uncreated_seasons(season_list = YAMLFile.open(FixtureDataTask::SEASON_LIST_PATH))
      logger.debug('selecting seasons now...')
      target_season_titles =
        season_list.reject { |season| Season.find_or_initialize_by(title: season.title).persisted? }.map(&:title)
      target_season_titles.each { |season_title| create_or_update_data(initialize_fixture_season(season_title)) }
    end

    def update_on_air_seasons
      logger.debug('selecting seasons now...')
      target_seasons = Season.on_air
      target_seasons.each { |season| create_or_update_data(season.to_h) }
    end

    def update_not_watchable_seasons
      logger.debug('selecting seasons now...')
      updated_season_titles = YAMLFile.open(FixtureDataTask::RENAMED_SEASON_LIST_PATH)
      target_seasons = Season.where(watchable: false).where.not(title: updated_season_titles)
      target_seasons.each { |season| create_or_update_data(season.to_h) }
    end

    def update_to_not_watchable
      logger.debug('selecting seasons now...')
      updated_season_titles = YAMLFile.open(FixtureDataTask::UPDATED_TO_NOT_WATCHABLE_LIST_PATH)
      target_seasons = Season.where(title: updated_season_titles)
      target_seasons.each { |season| update_watchable(season) }
    end

    def update_designated_seasons(target_string)
      initialize_dir(FixtureDataTask::SEASONS_DIR)
      logger.debug('selecting seasons now...')
      target_seasons = Season.where('title LIKE ?', "%#{target_string}%")
      target_seasons.each { |season| create_or_update_season(season.to_h) }
    end

    private

    def initialize_fixture_season(title)
      SeasonHash.new(title: title)
    end

    def create_or_update_data(fixture_season)
      start_log(fixture_season.title)
      fixture_season = Scraping::DanimeHeadStore.execute(fixture_season)
      fixture_season = Api::NicoContentsSearch.add_episode_info(fixture_season)
      target_season = create_or_update_season(fixture_season)
      create_or_update_episodes(fixture_season, belongs_to_season: target_season)
      finish_log(fixture_season.title)
    end

    def create_or_update_season(fixture_season)
      season = Season.find_or_initialize_by(title: fixture_season.title)
      attributes = hashie
      attributes.watchable = fixture_season.watchable
      attributes.thumbnail_url = fixture_season.thumbnail_url if fixture_season.key?(:thumbnail_url)
      attributes.outline = fixture_season.outline  if fixture_season.key?(:outline)
      attributes.cast = fixture_season.cast  if fixture_season.key?(:cast)
      attributes.staff = fixture_season.staff  if fixture_season.key?(:staff)
      attributes.produced_year = fixture_season.produced_year.to_s[%r(\d+)] if fixture_season.key?(:produced_year)
      attributes.copyright = fixture_season.copyright if fixture_season.key?(:copyright)
      season.update!(attributes)
      season
    end

    def create_or_update_episodes(fixture_season, belongs_to_season: nil)
      if fixture_season.key?(:episodes)
        fixture_season.episodes.each.with_index(1) do |fixture_episode, overall_number|
          episode = Episode.find_or_initialize_by(content_id: fixture_episode.content_id)
          attributes = hashie
          attributes.title = fixture_episode.title
          attributes.description = fixture_episode.description
          attributes.number_in_season = fixture_episode.episode_no
          attributes.overall_number = overall_number
          attributes.default_thread_id = fixture_episode.default_thread_id
          attributes.thumbnail_url = fixture_episode.thumbnail_url
          attributes.content_id = fixture_episode.content_id
          attributes.season = belongs_to_season
          episode.update!(attributes)
        end
      end
    end

    def update_watchable(season, watchable: false)
      start_log(season.title)
      season.update!(watchable: watchable)
      finish_log(season.title)
    end
  end
end
