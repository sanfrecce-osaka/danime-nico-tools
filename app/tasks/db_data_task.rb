class DBDataTask
  class << self
    def create_uncreated_seasons(season_list = YAMLFile.open(FixtureDataTask::SEASON_LIST_PATH))
      logger.debug('selecting seasons now...')
      target_season_titles =
        season_list.reject { |season| Season.find_or_initialize_by(title: season.title).persisted? }.map(&:title)
      target_season_titles.each { |season_title| create_data(initialize_fixture_season(season_title)) }
    end

    private

    def initialize_fixture_season(title)
      SeasonHash.new(title: title)
    end

    def create_data(fixture_season)
      start_log(fixture_season.title)
      fixture_season = Scraping::DanimeHeadStore.execute(fixture_season)
      fixture_season = Api::NicoContentsSearch.add_episode_info(fixture_season)
      created_season = create_season(fixture_season)
      create_episodes(fixture_season, belongs_to_season: created_season)
      finish_log(fixture_season.title)
    end

    def create_season(fixture_season)
      Season.find_or_create_by!(title: fixture_season.title) do |season|
        season.watchable = fixture_season.watchable
        season.thumbnail_url = fixture_season.thumbnail_url if fixture_season.key?(:thumbnail_url)
        season.outline = fixture_season.outline  if fixture_season.key?(:outline)
        season.cast = fixture_season.cast  if fixture_season.key?(:cast)
        season.staff = fixture_season.staff  if fixture_season.key?(:staff)
        season.produced_year = fixture_season.produced_year[%r(\d+)] if fixture_season.key?(:produced_year)
        season.copyright = fixture_season.copyright if fixture_season.key?(:copyright)
      end
    end

    def create_episodes(fixture_season, belongs_to_season: nil)
      if fixture_season.key?(:episodes)
        fixture_season.episodes.each.with_index(1) do |fixture_episode, overall_number|
          Episode.find_or_create_by!(content_id: fixture_episode.content_id) do |episode|
            episode.title = fixture_episode.title
            episode.description = fixture_episode.description
            episode.number_in_season = fixture_episode.episode_no
            episode.overall_number = overall_number
            episode.default_thread_id = fixture_episode.default_thread_id
            episode.thumbnail_url = fixture_episode.thumbnail_url
            episode.content_id = fixture_episode.content_id
            episode.season = belongs_to_season
          end
        end
      end
    end
  end
end
