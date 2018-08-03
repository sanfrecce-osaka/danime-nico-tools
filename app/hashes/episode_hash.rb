# frozen_string_literal: true

class EpisodeHash < BaseHash
  def ==(object)
    self.episode_no == object.episode_no && self.title == object.title
  end

  def nonexistent_episode?(season)
    Scraping::DanimeNicoBranchStore.find_season_including_nonexistent_episodes(season)&.episodes&.include?(self)
  end

  def update_only_different_title(season)
    different_title_episode = season.find_different_title_episode(self)
    update_by(different_title_episode.nico_branch) if different_title_episode
    self
  end
end
