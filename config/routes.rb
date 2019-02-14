# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'
  resources :seasons, only: %i(index show)
  resources :episodes, only: %i(show), param: :content_id
end
