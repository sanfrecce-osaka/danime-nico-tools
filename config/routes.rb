# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'
  resources :animes, only: :index
end
