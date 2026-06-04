Rails.application.routes.draw do
  # Landing page with locale support
  get "/:locale", to: "pages#home", as: :localized_root, constraints: { locale: /en|es/ }
  root "pages#home"

  # Public pages with optional locale
  scope "(:locale)", constraints: { locale: /en|es/ } do
    get "pricing", to: "pages#pricing", as: :pricing
    get "contact", to: "contacts#new", as: :contact
    post "contact", to: "contacts#create"
    get "privacy", to: "pages#privacy", as: :privacy
    get "terms", to: "pages#terms", as: :terms
  end


  resource :session
  resources :passwords, param: :token
  resource :registration, only: [ :new, :create ]
  resource :profile, only: [ :show, :update ]

  get "invite/:token", to: "invites#show", as: :invite
  post "invite/:token/accept", to: "invites#accept", as: :accept_invite

  resources :organizations, only: [ :new, :create, :show, :edit, :update ] do
    resources :tournaments, only: [ :index, :new, :create ]
  end

  resources :tournaments, only: [ :show ] do
    resources :fixtures, only: [ :index ]
    resource :leaderboard, only: [ :show ]
  end

  resources :fixtures, only: [] do
    resource :prediction, only: [ :show, :create, :update ]
  end

  get "dashboard", to: "dashboard#show"

  namespace :admin do
    get "/", to: "dashboard#show", as: :root
    resources :organizations, only: [ :index, :show ]
    resources :users, only: [ :index, :show ]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
