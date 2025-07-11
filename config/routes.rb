Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  root to: 'pages#index'
  resources :products
  resources :categories

  # resources :blogs
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
