Rails.application.routes.draw do
  devise_for :users

  resources :sessions, only: [:create] 

  controller :sessions do
    get '/check_logged_in', action: :check_logged_in, as: :checked_logged_in
    delete '/session', action: :destroy, as: :logout
  end

  resources :moto_routes

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
