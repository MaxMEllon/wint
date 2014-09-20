Wint::Application.routes.draw do
  ##--  User
  get   'users'                    => 'users#list'
  get   'users/new'                => 'users#new'
  post  'users/new'                => 'users#create'
  get   'users/:uid/edit'          => 'users#edit', as: :users_edit
  patch 'users/:uid/edit'          => 'users#update'
  get   'users/:uid/edit_password' => 'users#edit_password', as: :users_edit_password
  patch 'users/:uid/edit_password' => 'users#update_password', as: :users_update_password
  get   'users/:uid/toggle'        => 'users#toggle', as: :users_toggle

  ##--  League
  get  'leagues'                   => 'leagues#list'
  get  'leagues/new'               => 'leagues#new'
  post 'leagues/new'               => 'leagues#create'
  get  'leagues/:lid/edit'         => 'leagues#edit', as: :leagues_edit
  post 'leagues/:lid/edit'         => 'leagues#update'
  get  'leagues/:lid/toggle'       => 'leagues#toggle', as: :leagues_toggle
  get  'leagues/:lid/toggle_analy' => 'leagues#toggle_analy', as: :leagues_toggle_analy
end

