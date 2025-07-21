Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  root to: 'pages#index'
  resources :products
  resources :categories

  resource :cart, only: [:show] do
    post 'add_item/:product_id', to: 'carts#add_item', as: 'add_item'
    delete 'remove_item/:product_id', to: 'carts#remove_item', as: 'remove_item'
  end

  resources :orders do
    resources :payments, except: [:destroy]
  end

  resources :payments, except: [:destroy] do
    collection do
      get 'new/:order_id', to: 'payments#new', as: 'new_with_order'
    end
  end

  # resources :blogs
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
