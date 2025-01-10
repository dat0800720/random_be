Rails.application.routes.draw do
  devise_for :users, path: "users",
  path_names: {
    sign_in: "login",
    sign_out: "logout",
    registration: "signup",
    password: "reset_password"
  },
  controllers: {
    sessions: "api/v1/user/sessions",
    registrations: "api/v1/user/registrations",
    passwords: "api/v1/user/passwords"
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
