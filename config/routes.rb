Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resource :session, only: %i[new create destroy]
  resource :registration, only: %i[new create]

  get "calendar" => "calendar#show", as: :calendar
  get "upcoming" => "calendar#upcoming", as: :upcoming
  get "settings" => "calendar#settings", as: :settings
  patch "settings/profile" => "calendar#update_profile", as: :settings_profile
  patch "settings/password" => "calendar#update_password", as: :settings_password
  patch "settings/input" => "calendar#update_input_configuration", as: :settings_input_configuration

  resources :events, only: %i[create update destroy]

  root "sessions#new"
end
