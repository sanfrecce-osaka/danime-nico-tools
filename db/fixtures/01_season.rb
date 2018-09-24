# frozen_string_literal: true

SeasonHash.already_created.each do |season|
  Season.seed(:title) do |s|
    s.title = season.title
    s.watchable = season.watchable
    s.thumbnail_url = season.thumbnail_url if season.key?(:thumbnail_url)
    s.outline = season.outline  if season.key?(:outline)
    s.cast = season.cast  if season.key?(:cast)
    s.staff = season.staff  if season.key?(:staff)
    s.produced_year = season.produced_year[%r(\d+)] if season.key?(:produced_year)
    s.copyright = season.copyright if season.key?(:copyright)
  end
end
