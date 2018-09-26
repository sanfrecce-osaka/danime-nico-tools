# frozen_string_literal: true

class SeasonHash < BaseHash
  class << self
    def already_created
      Dir.glob(FixtureDataTask::SEASONS_PATH).map { |path| YAMLFile.open(path).merge(file_path: path) }
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
    return false unless watchable
    %r(次話→) === episodes.last.description
  end
end
