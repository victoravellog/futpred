Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :registration, only: [ :new, :create ]
  resources :organizations, only: [ :new, :create, :show ] do
    resources :tournaments, only: [ :index, :new, :create ]
  end

  resources :tournaments, only: [ :show ] do
    resources :fixtures, only: [ :index ]
    resource :leaderboard, only: [ :show ]
  end

  resources :fixtures, only: [] do
    resource :prediction, only: [ :show, :create, :update ]
  end

  root "dashboard#show"

  get "up" => "rails/health#show", as: :rails_health_check
end
