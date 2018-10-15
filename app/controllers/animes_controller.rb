# frozen_string_literal: true

class AnimesController < ApplicationController
  def index
    @search_form = Form::Search.new(search_params)
    @seasons =
      if @search_form.keywords.present?
        Season.search_by(@search_form).limit(5).order(:title)
      else
        Season.random(5)
      end
    @episodes =
      if @search_form.keywords.present?
        Episode.joins(:season).eager_load(:season)
          .search_by(@search_form).limit(6)
          .order('seasons.title ASC, overall_number ASC')
      else
        Episode.joins(:season).eager_load(:season).random(6)
      end
  end

  private

  def search_params
    if params[:form_search].present?
      params.require(:form_search).permit(:keywords)
    else
      {}
    end
  end
end
