Wint::Application.routes.draw do
  ##================================================
  ##  Session
  ##================================================

  ##--  Session
  get  'login'          => 'sessions#new', as: :login
  post 'login'          => 'sessions#create'
  get  'logout'         => 'sessions#destroy', as: :logout
  get  'destroy_player' => 'sessions#destroy_player', as: :destroy_player

  ##================================================
  ##  Analysis
  ##================================================

  ##--  Analysis
  get 'analysis'                 => 'analysis#list', as: :analysis_list
  get 'analysis/:lid'            => 'analysis#league', as: :analysis_league
  get 'analysis/:lid/refresh'    => 'analysis#refresh', as: :analysis_refresh
  get 'analysis/:lid/strategies' => 'analysis#strategies', as: :analysis_strategies
  get 'analysis/:lid/ranking'    => 'analysis#ranking', as: :analysis_ranking
  get 'analysis/:lid/code/:sid'  => 'analysis#code', as: :analysis_player_code
  get 'analysis/:lid/:pid'       => 'analysis#player', as: :analysis_player
  get 'analysis/:lid/:pid/:num'  => 'analysis#strategy', as: :analysis_strategy

  ##================================================
  ##  Main
  ##================================================
  ##--  Main
  get   'main/select'                => 'mains#select', as: :main_select
  get   'main/set_player/:pid'       => 'mains#set_player', as: :main_set_player
  get   'main/ranking'               => 'mains#ranking', as: :main_ranking
  get   'main/mypage'                => 'mains#mypage', as: :main_mypage
  get   'main/mypage/strategy/:num'  => 'mains#strategy', as: :main_strategy
  get   'main/mypage/submit'         => 'submits#new', as: :submits_new
  post  'main/mypage/submit'         => 'submits#create'
  get   'main/edit_name'             => 'mains#edit_name', as: :main_edit_name
  patch 'main/edit_name'             => 'mains#update_name'
  get   'main/edit_password'         => 'mains#edit_password', as: :main_edit_password
  patch 'main/edit_password'         => 'mains#update_password'

  ##================================================
  ##  Admin
  ##================================================

  ##--  User
  get   'admin/users'                    => 'users#list', as: :users
  get   'admin/users/new'                => 'users#new', as: :users_new
  post  'admin/users/new'                => 'users#create'
  get   'admin/users/:uid/edit'          => 'users#edit', as: :users_edit
  patch 'admin/users/:uid/edit'          => 'users#update'
  get   'admin/users/:uid/edit_password' => 'users#edit_password', as: :users_edit_password
  patch 'admin/users/:uid/edit_password' => 'users#update_password', as: :users_update_password
  get   'admin/users/:uid/toggle'        => 'users#toggle', as: :users_toggle

  ##--  League
  get  'admin/leagues'                   => 'leagues#list', as: :leagues
  get  'admin/leagues/new'               => 'leagues#new', as: :leagues_new
  post 'admin/leagues/new'               => 'leagues#create'
  get  'admin/leagues/:lid/edit'         => 'leagues#edit', as: :leagues_edit
  post 'admin/leagues/:lid/edit'         => 'leagues#update'
  get  'admin/leagues/:lid/toggle'       => 'leagues#toggle', as: :leagues_toggle
  get  'admin/leagues/:lid/toggle_analy' => 'leagues#toggle_analy', as: :leagues_toggle_analy

  ##--  Player
  get   'admin/players'             => 'players#list', as: :players
  get   'admin/players/select'      => 'players#select', as: :players_select
  get   'admin/players/new_many'    => 'players#new_many', as: :players_new_many
  post  'admin/players/new_many'    => 'players#create_many'
  get   'admin/players/new'         => 'players#new', as: :players_new
  post  'admin/players/new'         => 'players#create'
  get   'admin/players/:pid/edit'   => 'players#edit', as: :players_edit
  patch 'admin/players/:pid/edit'   => 'players#update'
  get   'admin/players/:pid/toggle' => 'players#toggle', as: :players_toggle
end

