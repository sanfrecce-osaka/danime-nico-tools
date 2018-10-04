class DailyTask
  class << self
    def update_fixtures
      FixtureDataTask.execute(:season_list)
      FixtureDataTask.execute(:uncreated_seasons)
      FixtureDataTask.execute(:on_air_seasons)
      FixtureDataTask.execute(:not_watchable_seasons)
    end

    def update_db
      FixtureDataTask.execute(:season_list)
      DBDataTask.execute(:uncreated_seasons)
      DBDataTask.execute(:on_air_seasons)
      DBDataTask.execute(:not_watchable_seasons)
    end
  end
end
