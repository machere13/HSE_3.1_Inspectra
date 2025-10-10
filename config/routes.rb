Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  
  namespace :api do
    namespace :v1 do
      get 'health', to: 'health#index'
      post 'auth', to: 'auth#login_or_register'
      post 'auth/verify', to: 'auth#verify_email'
      post 'auth/resend', to: 'auth#resend_verification_code'
      get 'auth/me', to: 'auth#me'
      get 'auth/supported-domains', to: 'auth#supported_email_domains'
      
      resources :achievements, only: [:index] do
        collection do
          get 'my', to: 'achievements#user_achievements'
          get 'by_category', to: 'achievements#by_category'
          post 'test/interactive', to: 'achievements#test_interactive_completion'
          post 'test/consecutive_days', to: 'achievements#test_consecutive_days'
          post 'test/registration', to: 'achievements#test_registration_order'
        end
      end

      resources :days, only: [:index, :show] do
        resources :articles, only: [:index, :show]
        resources :content_items, only: [:index]
      end
    end
  end

  root 'pages#home'
  get 'about', to: 'pages#about'
  
  resources :days, only: [:show] do
    resources :articles, only: [:show]
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
