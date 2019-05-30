# frozen_string_literal: true

class Season < ApplicationRecord
  include Searchable

  has_many :episodes, dependent: :destroy

  validates :title, presence: true
  validates :watchable, inclusion: { in: [true, false] }
  validates :produced_year, numericality: { only_integer: true }, allow_nil: true

  scope :random, -> (number) { where(id: pluck(:id).sample(number)) }
  scope :on_air, -> { where(title: YAMLFile.open(FixtureDataTask::ON_AIR_SEASON_LIST_PATH)) }

  class << self
    def target_columns_for_keyword_search
      %w(title outline cast staff copyright)
    end

    private

    def search_conditions(search_form)
      case search_form.keyword_type
      when :season_title
        { watchable_true: true, title_cont_all: search_form.split_keywords }
      when :cast_name
        { watchable_true: true, cast_cont_all: search_form.split_keywords }
      when :staff_name
        { watchable_true: true, staff_cont_all: search_form.split_keywords }
      when :keyword
        { watchable_true: true, groupings: keyword_conditions(search_form) }
      end
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

  def to_meta_tags
    { title: title, description: outline }
  end
end
