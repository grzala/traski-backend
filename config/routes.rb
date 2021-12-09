Rails.application.routes.draw do
  get 'moto_routes/show'
  devise_for :users

  resources :sessions, only: [:create] 

  controller :sessions do
    get '/check_logged_in', action: :check_logged_in, as: :checked_logged_in
    delete '/session', action: :destroy, as: :logout
  end

  resources :moto_routes
  controller :moto_routes do
    post '/moto_routes/switch_favourite', action: :switch_favourite, as: :switch_favourite
  end




  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
