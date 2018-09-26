# frozen_string_literal: true

class Season < ApplicationRecord
  has_many :episodes

  validates :title, presence: true
  validates :watchable, inclusion: { in: [true, false] }
  validates :produced_year, numericality: { only_integer: true }, allow_nil: true

  def on_air?
    return false unless watchable
    %r(次話→) === episodes.order(:overall_number).last.description
  end

  def to_h
    season = SeasonHash.new(attributes)
    season.episodes = episodes.map { |episode| EpisodeHash.new(episode.attributes) }
    season
  end
end
