# config/routes

TestSignetRails::Application.routes.draw do
  get "home/index"

  get '/signout' => 'sessions#destroy', as: :signout

  get '/signet/google/auth_callback' => 'sessions#create'

  root to: 'home#index'
end
