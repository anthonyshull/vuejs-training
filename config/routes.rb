Rails.application.routes.draw do
  root 'boards#index'
  resources :boards, only: [:index]
  resources :tasks, only: [:create]
  post 'tasks/:id/delete', to: 'tasks#destroy'
  post 'tasks/:id/update', to: 'tasks#update'
end
