# frozen_string_literal: true

class Episode < ApplicationRecord
  belongs_to :season

  validates :title, presence: true
  validates :description, presence: true
  validates :overall_number, presence: true, numericality: { only_integer: true }
  validates :default_thread_id, presence: true, numericality: { only_integer: true }
  validates :thumbnail_url, presence: true
  validates :content_id, presence: true

  def to_param
    content_id
  end
end
