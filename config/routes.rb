Rails.application.routes.draw do
  root "sessions#new"

  resource :session, only: [:new, :create, :destroy]

  namespace :admin do
    resource :session, only: [:new, :create, :destroy]
    resources :books
    resources :users, only: [:index]
    resources :tags
    root to: 'books#index'
  end

  resources :books, only: [:index, :show]
  resources :tags, only: [:show]
  resources :users, only: [:new, :create, :show]

  resource :cart, only: [:show] do
    post 'add', to: 'carts#add'
    delete 'remove/:id', to: 'carts#remove', as: 'remove'
  end

  resources :orders, only: [:create, :show]
end
