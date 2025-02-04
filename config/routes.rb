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

  get "up" => "rails/health#show", as: :rails_health_check
end
