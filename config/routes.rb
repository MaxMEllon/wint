Wint::Application.routes.draw do
  ##--  User
  get   'users'                    => 'users#list'
  get   'users/new'                => 'users#new'
  post  'users/new'                => 'users#create'
  get   'users/:uid/edit'          => 'users#edit', as: :users_edit
  patch 'users/:uid/edit'          => 'users#update'
  get   'users/:uid/edit_password' => 'users#edit_password', as: :users_edit_password
  patch 'users/:uid/edit_password' => 'users#update_password', as: :users_update_password

end

