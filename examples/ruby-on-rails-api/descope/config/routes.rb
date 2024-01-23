Rails.application.routes.draw do
  get 'session/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root 'homepage#index'

  get '/get_roles' => 'session#get_roles', as: :get_roles
  get '/get_role_data' => 'session#get_role_data', as: :get_role_data

  get '*path', to: 'homepage#index', constraints: lambda  { |request|
    !request.xhr? && request.format.html?
  }
end
