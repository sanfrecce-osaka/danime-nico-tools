# frozen_string_literal: true

seasons = Dir.glob(DataTask::SEASONS_PATH).map { |path| YAMLFile.open(path) }

seasons.each.with_index(1) do |season, season_id|
  Season.seed do |s|
    s.id = season_id
    s.title = season.title
    s.watchable = season.watchable
    s.thumbnail_url = season.thumbnail_url if season.key?(:thumbnail_url)
    s.outline = season.outline  if season.key?(:outline)
    s.cast = season.cast  if season.key?(:cast)
    s.staff = season.staff  if season.key?(:staff)
    s.produced_year = season.produced_year[%r(\d+)] if season.key?(:produced_year)
    s.copyright = season.copyright if season.key?(:copyright)
  end

  if season.key?(:episodes)
    season.episodes.each.with_index(1) do |episode, overall_number|
      Episode.seed(:content_id) do |s|
        s.title = episode.title
        s.description = episode.description
        s.number_in_season = episode.episode_no
        s.overall_number = overall_number
        s.default_thread_id = episode.default_thread_id
        s.thumbnail_url = episode.thumbnail_url
        s.content_id = episode.content_id
        s.season_id = season_id
      end
    end
  end
end
