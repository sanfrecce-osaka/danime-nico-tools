# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @seasons = Season.where(watchable: true).random(8)
    @episodes = Episode.joins(:season).eager_load(:season).where('seasons.watchable = ?', true).random(8)
    @new_seasons = Season.where(watchable: true).order(updated_at: :desc).limit(8)
  end
end
