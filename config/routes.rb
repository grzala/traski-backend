Rails.application.routes.draw do
  devise_for :users
  get '/check_logged_in', to: 'sessions#check_logged_in', as: 'check_logged_in'


  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
