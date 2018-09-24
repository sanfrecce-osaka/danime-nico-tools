# frozen_string_literal: true

class SeasonHash < BaseHash
  class << self
    def already_created
      Dir.glob(DataTask::SEASONS_PATH).map { |path| YAMLFile.open(path).merge(file_path: path) }
    end
  end

  def ==(object)
    self.title == object.title
  end

  def has_nonexistent_episode?
    Scraping::DanimeNicoBranchStore::SEASONS_INCLUDING_NONEXISTENT_EPISODES.include?(self)
  end

  def has_different_title_episode?
    Scraping::DanimeNicoBranchStore::SEASONS_INCLUDING_DIFFERENT_TITLE_EPISODES.include?(self)
  end

  def find_different_title_episode(episode)
    Scraping::DanimeNicoBranchStore
      .find_season_including_different_title_episode(self)
      &.episodes
      &.find { |different_title_episode| different_title_episode.head == episode }
  end

  def on_air?
    next_episode_content_ids =
      episodes
        .map { |episode| episode.description.match(%r(次話→((so\d+)|[[:blank:]]|$))) }
        .reject(&:nil?)
        .map { |match_data| match_data[1] }
    (next_episode_content_ids - episodes.map(&:content_id)).length > 0
  end
end
