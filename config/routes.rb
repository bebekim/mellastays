 # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  resources :tweets

  # Jumpstart views
  if Rails.env.development?
    mount Jumpstart::Engine, at: '/jumpstart'
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
    resource :docs
    namespace :docs do
      resource :javascript
      resource :typography
      resource :button
      resource :form
    end
  end

  # Administrate
  authenticate :user, lambda { |u| u.admin? } do
    namespace :admin do
      if defined?(Sidekiq)
        require 'sidekiq/web'
        mount Sidekiq::Web => '/sidekiq'
      end

      resources :users
      resources :subscriptions
      resources :charges
      namespace :user do
        resources :connected_accounts
      end

      root to: "users#index"
    end
  end

  # User account
  devise_for :users,
             controllers: {
               masquerades: 'jumpstart/masquerades',
               omniauth_callbacks: 'users/omniauth_callbacks',
               registrations: 'users/registrations',
             }

  resource :password

  # Payments
  resource :card
  resource :subscription do
    patch :info
    patch :resume
  end
  resources :charges

  namespace :user, module: :users do
    resources :connected_accounts
  end

  scope controller: :static do
    get :about
    get :terms
    get :privacy
    get :pricing
  end

  authenticated :user do
    root to: "dashboard#show"
  end

  # Public marketing homepage
  root to: "static#index"
end
