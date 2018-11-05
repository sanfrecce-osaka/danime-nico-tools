# frozen_string_literal: true

class SearchCategory < ActiveHash::Base
  self.data = [
    { id: 1, type: :all, name: '全て' },
    { id: 2, type: :season, name: '作品' },
    { id: 3, type: :episode, name: '動画' }
  ]

  def all?
    type == :all
  end

  def season?
    type == :season
  end

  def episode?
    type == :episode
  end

  def include_season?
    all? || season?
  end

  def include_episode?
    all? || episode?
  end
end
