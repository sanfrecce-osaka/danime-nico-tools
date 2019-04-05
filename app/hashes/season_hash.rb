# frozen_string_literal: true

class SeasonHash < BaseHash
  class << self
    def already_created
      Dir.glob(FixtureDataTask::SEASONS_PATH).map { |path| YAMLFile.open(path).merge(file_path: path) }
    end

    def on_air
      target_titles = YAMLFile.open(FixtureDataTask::ON_AIR_SEASON_LIST_PATH)
      already_created.select { |season| target_titles.include?(season.title) }
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
    return true if not_begin_yet?
    %r(次話→) === episodes.last.description
  end

  def add_next_content_id(current_episode, current_overall_number)
    if episode_without_episode_no_and_title?(current_episode)
      if current_overall_number == 1
        season_list = YAMLFile.open(FixtureDataTask::SEASON_LIST_PATH)
        target_member = season_list.find { |member| member.title == title }
        self.next_content_id = target_member.first_episode_url[%r(so\d+)]
      else
        self.next_content_id = %r(次話→(so\d+)).match(delete(:before_episode).description)[1]
      end
    end
  end

  def add_before_episode(current_episode, current_overall_number)
    if episode_without_episode_no_and_title?(current_episode) && current_overall_number < episodes.length
      self.before_episode = current_episode
    end
  end

  def not_begin_yet?
    watchable && episodes.blank?
  end

  def title_for_regexp
    "(?:#{titles_with_pipe})"
  end

  def original_or_different_title
    season_with_different_title = Scraping::DanimeNicoBranchStore.find_season_with_different_title(self)
    season_with_different_title.present? ? season_with_different_title.different_titlt : title
  end

  private

  def episode_without_episode_no_and_title?(episode)
    title == episode.title && episode.episode_no.blank?
  end

  def titles_with_pipe
    [title, Scraping::DanimeNicoBranchStore.find_season_with_different_title(self)&.different_title]
      .reject(&:nil?)
      .join('|')
  end
end
