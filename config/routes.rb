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

      post 'auth/password/forgot', to: 'auth#forgot_password'
      post 'auth/password/reset', to: 'auth#reset_password'
    end
  end

  get 'about', to: 'pages#about'
  get 'auth', to: redirect('/auth/login')
  get 'reset_password', to: 'auth#reset'
  scope :auth do
    get 'login', to: 'auth#login'
    post 'login', to: 'auth#login_submit'
    get 'verify', to: 'auth#verify'
    get 'forgot', to: 'auth#forgot'
    post 'forgot', to: 'auth#forgot_submit'
    get 'reset', to: 'auth#reset'
    post 'reset', to: 'auth#reset_submit'
    post 'verify', to: 'auth#verify_submit'
    post 'resend', to: 'auth#resend'
  end
  
  resources :days, only: [:show] do
    resources :articles, only: [:show]
  end

  namespace :admin do
    resources :days do
      resources :articles
      resources :content_items
    end
  end

  get 'admin', to: redirect('/admin/days')

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  root 'pages#home'

end
