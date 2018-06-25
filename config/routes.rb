# frozen_string_literal: true

Rails.application.routes.draw do
  resources :animes, only: :index
end
