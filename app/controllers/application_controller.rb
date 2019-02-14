# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_season_search_form

  def set_season_search_form
    @season_search_form = Form::SeasonSearch.new(search_params)
  end

  def search_params
    if params[:form_season_search].present?
      params.require(:form_season_search).permit(:keywords, :keyword_type)
    else
      {}
    end
  end
end
