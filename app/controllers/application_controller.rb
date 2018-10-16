# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_search_form

  def set_search_form
    @search_form = Form::Search.new(search_params)
  end

  def search_params
    if params[:form_search].present?
      params.require(:form_search).permit(:keywords)
    else
      {}
    end
  end
end
