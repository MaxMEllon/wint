Wint::Application.routes.draw do
  ##--  Session
  get  'sessions/new' => 'sessions#new', as: :logins
  post 'sessions/new' => 'sessions#create'

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

  ##--  Player
  get   'players'             => 'players#list', as: :players
  get   'players/select'      => 'players#select', as: :players_select
  get   'players/new_many'    => 'players#new_many'
  post  'players/new_many'    => 'players#create_many'
  get   'players/new'         => 'players#new'
  post  'players/new'         => 'players#create'
  get   'players/:pid/edit'   => 'players#edit', as: :players_edit
  patch 'players/:pid/edit'   => 'players#update'
  get   'players/:pid/toggle' => 'players#toggle', as: :players_toggle

  ##--  Main
  get 'mains/select' => 'leagues#select', as: :mains_league_select
  get 'mains/:lid/mypage' => 'mains#mypage', as: :mains_mypage
end

