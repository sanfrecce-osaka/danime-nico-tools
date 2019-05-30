# frozen_string_literal: true

class Episode < ApplicationRecord
  include Searchable

  belongs_to :season

  validates :description, presence: true
  validates :overall_number, presence: true, numericality: { only_integer: true }
  validates :default_thread_id, presence: true, numericality: { only_integer: true }
  validates :thumbnail_url, presence: true
  validates :content_id, presence: true

  scope :random, -> (number) { where(id: pluck(:id).sample(number)) }

  class << self
    def target_columns_for_keyword_search
      %w(title description number_in_season)
    end

    private

    def search_conditions(search_form)
      { season_watchable_true: true, groupings: keyword_conditions(search_form) }
    end

    def keyword_conditions(search_form)
      search_form
        .split_keywords
        .map { |keyword| { key_for_keyword_search => keyword } }
    end

    def targets_for_keyword_search
      target_columns_for_keyword_search.concat(
        Season.target_columns_for_keyword_search.map { |column| "season_#{column}" }
      )
    end
  end

  def nico_url
    "http://www.nicovideo.jp/watch/#{content_id}"
  end

  def displayed_number_in_season
    if with_same_season_title? && number_in_season.blank?
      "##{overall_number}"
    else
      number_in_season
    end
  end

  def displayed_title
    with_same_season_title? ? '' : title
  end

  def with_same_season_title?
    season.title == title
  end

  def displayed_season_title(with_season_title)
    if with_same_season_title?
      season.title
    else
      with_season_title ? season.title : ''
    end
  end

  def full_title(with_season_title)
    [
      displayed_season_title(with_season_title),
      displayed_number_in_season,
      displayed_title
    ].select(&:present?).join('　')
  end

  def thumbnail_https_url
    thumbnail_url.gsub('http:', 'https:')
  end

  def to_param
    content_id
  end
end
