require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  use_doorkeeper do
    skip_controllers :applications, :authorized_applications
  end
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    namespace :v1 do
      post 'login' => 'sessions#create'
      delete 'logout' => 'sessions#destroy'
      resources :products, only: %i[index show]
      resources :orders, only: %i[create show index]
    end
  end

  devise_for :users, controllers: { registrations: 'users/registrations' }
  root to: 'pages#index'
  resources :products do
    member do
      get 'download', to: 'products#download'
      post 'save_review', to: 'products#save_review'
      delete 'delete_review', to: 'products#delete_review'
    end

    collection do
      get 'bulk_import', to: 'products#bulk_import', as: 'bulk_import'
      post 'bulk_import', to: 'products#bulk_import_action', as: 'bulk_import_action'
      get 'sample_csv', to: 'products#sample_csv', as: 'sample_csv'
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

    get 'check_stripe_payment/:payment_id', to: 'payments#check_stripe_payment', as: 'check_stripe_payment'
  end

  get 'selling-point', to: 'pages#selling_point', as: 'selling_point'

  namespace :administration do
    resources :users
    resources :orders
    resources :payments, only: %i[index]
    resources :reviews, only: %i[index destroy]
  end

  # resources :blogs
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
