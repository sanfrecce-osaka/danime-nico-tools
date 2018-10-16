# frozen_string_literal: true

class Season < ApplicationRecord
  include Searchable

  has_many :episodes, dependent: :destroy

  validates :title, presence: true
  validates :watchable, inclusion: { in: [true, false] }
  validates :produced_year, numericality: { only_integer: true }, allow_nil: true

  scope :random, -> (number) { where(id: pluck(:id).sample(number)) }

  class << self
    def target_columns_for_keyword_search
      %w(title outline cast staff copyright)
    end

    private

    def search_conditions(search_form)
      { watchable_true: true, groupings: keyword_conditions(search_form) }
    end

    def keyword_conditions(search_form)
      search_form
        .split_keywords
        .map { |keyword| { m: 'or', key_for_keyword_search => keyword, produced_year_eq: keyword } }
    end

    def targets_for_keyword_search
      target_columns_for_keyword_search
    end
  end

  def on_air?
    return false unless watchable
    return true if not_begin_yet?
    %r(次話→) === episodes.order(:overall_number).last.description
  end

  def not_begin_yet?
    watchable && episodes.blank?
  end

  def to_h
    season = SeasonHash.new(attributes)
    season.episodes = episodes.map { |episode| EpisodeHash.new(episode.attributes) }
    season
  end
end
