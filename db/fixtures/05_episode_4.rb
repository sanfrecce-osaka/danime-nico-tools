# frozen_string_literal: true

SeasonHash.already_created.select { |season| season.fixture_no.between?(3001, 4000) }.each do |season|
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
        s.season = Season.find_by(title: season.title)
      end
    end
  end
end
