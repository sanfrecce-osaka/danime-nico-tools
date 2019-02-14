# frozen_string_literal: true

class AnimesController < ApplicationController
  def index
    @seasons =
      if @season_search_form.keywords.present?
        if @season_search_form.keyword_type.include_season?
          Season.search_by(@season_search_form).order(:title).page(season_page_params).per(12)
        end
      end
    @episodes =
      if @season_search_form.keywords.present?
        if @season_search_form.keyword_type.include_episode?
          Episode
            .joins(:season).eager_load(:season)
            .search_by(@season_search_form)
            .order('seasons.title ASC, overall_number ASC')
            .page(episode_page_params).per(12)
        end
      end
  end

  private

  def season_page_params
    params[:season_page].present? ? params[:season_page] : 1
  end

  def episode_page_params
    params[:episode_page].present? ? params[:episode_page] : 1
  end
end
