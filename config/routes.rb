Rails.application.routes.draw do
  resources :servers do
    get "retry"
  	get "nginx_logs"
    
    resources :logs

    resources :memberships, only: [:index, :create, :destroy], param: :user_id

  	resources :apps do
      get 'rails_logs'
      get 'deploy'
    end
  end

  #get 'webhook/:hook_id' => "webhook#index"
  post 'webhook/:hook_id' => "webhook#index"

  resources :scripts
  devise_for :users

  get 'pricing' => "dashboard#pricing"

  mount StripeEvent::Engine, at: '/stripe/webhook'


  resource :subscription
  resource :card
  resources :charges
  
  namespace :admin do
  	resources :users
  	resources :system_info, only: [:index]
  end

  root 'dashboard#index'

  mount ActionCable.server, at: '/cable'
end
