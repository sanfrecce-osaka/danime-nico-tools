# frozen_string_literal: true

class EpisodesController < ApplicationController
  def index
    @episodes =
      if @season_search_form.keywords.present?
        Episode
          .joins(:season).eager_load(:season)
          .search_by(@season_search_form)
          .order('seasons.title ASC, overall_number ASC')
          .page(page_params).per(10)
      else
        Episode
          .joins(:season).eager_load(:season)
          .random(10)
      end
  end

  def show
    @episode = Episode.joins(:season).eager_load(:season).find_by(content_id: params[:content_id])
    unless @episode.season.watchable
      flash[:warning] = '指定された動画は現在公開されていません'
      redirect_to :episodes
    end
  end

  private

  def page_params
    params[:page].present? ? params[:page] : 1
  end
end
