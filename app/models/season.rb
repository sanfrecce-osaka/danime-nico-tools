# frozen_string_literal: true

class Season < ApplicationRecord
  has_many :episodes

  validates :title, presence: true
  validates :watchable, inclusion: { in: [true, false] }
  validates :produced_year, numericality: { only_integer: true }
end
