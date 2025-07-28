require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  devise_for :users, controllers: { registrations: 'users/registrations' }
  root to: 'pages#index'
  resources :products do
    member do
      get 'download', to: 'products#download'
    end
  end
  resources :categories
  resources :uploads, only: %i[index new create]

  resource :cart, only: [:show] do
    post 'add_item/:product_id', to: 'carts#add_item', as: 'add_item'
    delete 'remove_item/:product_id', to: 'carts#remove_item', as: 'remove_item'
  end

  resources :orders do
    member do
      post 'cancel', to: 'orders#cancel_order', as: 'cancel'
    end

    resources :payments, except: [:destroy]
  end

  resources :payments, except: [:destroy] do
    collection do
      get 'new/:order_id', to: 'payments#new', as: 'new_with_order'
    end
  end

  get 'selling-point', to: 'pages#selling_point', as: 'selling_point'

  # resources :blogs
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
