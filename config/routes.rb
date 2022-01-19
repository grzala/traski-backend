Rails.application.routes.draw do
  get 'moto_routes/show'
  #devise_for :users
  devise_for :users, :controllers => { registrations: 'users/registrations' }

  resources :sessions, only: [:create] 

  controller :sessions do
    get '/check_logged_in', action: :check_logged_in, as: :checked_logged_in
    delete '/session', action: :destroy, as: :logout
  end

  controller :moto_routes do
    get '/moto_routes/:id/is_favourite', action: :is_favourite, as: :is_route_favourite
    post '/moto_routes/switch_favourite', action: :switch_favourite, as: :switch_route_favourite
    post '/moto_routes/cast_rating_vote', action: :vote, as: :route_vote
    get '/moto_routes/:id/get_user_vote', action: :get_user_vote, as: :get_user_route_vote

    get '/moto_routes/:id/can_edit', action: :can_edit, as: :can_edit

    get '/moto_routes/user_routes/:page/:user_id', action: :user_routes, as: :user_routes
    get '/moto_routes/top/:page', action: :get_top, as: :get_top
    get '/moto_routes/user_favourites/:page', action: :user_favourites, as: :user_favourites

    get '/moto_routes/recent', action: :get_recent, as: :recent_routes
    post '/moto_routes/in_area', action: :get_in_area, as: :in_area_routes

  end
  resources :moto_routes

  resources :comments, only: [:destroy]
  controller :comments do
    get '/moto_routes/:moto_route_id/comments', action: :get_for_route, as: :get_comments_for_route
    post '/moto_routes/:moto_route_id/comments', action: :create, as: :create_comment
  end

  controller :accidents do
    post '/accidents', action: :bounds, as: :bounds
    post '/accidents/filters', action: :get_filtered, as: :get_filtered
  end



  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
