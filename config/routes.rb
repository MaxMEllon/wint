Wint::Application.routes.draw do
  ##--  User
  get  'users/list'      => 'users#list'
  get  'users/new'       => 'users#new'
  post 'users/new'       => 'users#create'
  get  'users/:uid/edit' => 'users#edit', as: :users_edit
  post 'users/:uid/edit' => 'users#update'

end

