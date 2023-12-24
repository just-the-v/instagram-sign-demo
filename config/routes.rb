# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  get '/instagram/auth' => 'users/omniauth_callbacks#instagram'
  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'posts#index'
  get '/posts/fetch_instagram' => 'posts#fetch_instagram'
  delete '/posts/destroy' => 'posts#destroy'
end
