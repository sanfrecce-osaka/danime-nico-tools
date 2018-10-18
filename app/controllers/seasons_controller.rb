# frozen_string_literal: true

class SeasonsController < ApplicationController
  def index
    @seasons =
      if @search_form.keywords.present?
        Season.search_by(@search_form).order(:title).page(page_params).per(10)
      else
        Season.random(10)
      end
  end

  def show
    @season = Season.find(params[:id])
    unless @season.watchable
      flash[:warning] = '指定された作品は現在公開されていません'
      redirect_to :seasons
    end
    @episodes =
      Episode
        .joins(:season).eager_load(:season)
        .where(season_id: params[:id])
        .order(:overall_number)
        .page(page_params).per(10)
  end

  private

  def page_params
    params[:page].present? ? params[:page] : 1
  end
end
