Rails.application.routes.draw do
  if defined?(ActiveStorage::Engine)
    mount ActiveStorage::Engine => '/rails/active_storage'
  end
  
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

      resources :weeks, only: [:index, :show] do
        resources :articles, only: [:index, :show]
        resources :content_items, only: [:index]
      end

      post 'auth/password/forgot', to: 'auth#forgot_password'
      post 'auth/password/reset', to: 'auth#reset_password'
    end
  end

  get 'about', to: 'pages#about'
  get 'profile', to: 'pages#profile'
  patch 'profile/select_title', to: 'pages#select_title', as: 'select_title'
  patch 'profile/update_name', to: 'pages#update_name', as: 'update_name'
  patch 'profile/update_avatar', to: 'pages#update_avatar', as: 'update_avatar'
  post 'profile/request_password_change', to: 'pages#request_password_change', as: 'request_password_change'
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
  
  resources :weeks, only: [:show] do
    resources :articles, only: [:show]
  end

  namespace :admin do
    get 'dashboard', to: 'dashboard#index'
    
    resources :users, only: [:index, :show, :edit, :update]
    
    resources :weeks do
      resources :articles
      resources :content_items
    end

    resources :jwt_secrets, only: [:index, :create] do
      collection do
        post 'rotate', to: 'jwt_secrets#rotate'
        get 'stats', to: 'jwt_secrets#stats'
      end
    end
  end

  get 'admin', to: redirect('/admin/dashboard')

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  root 'pages#home'

  # Catch-all for non-existent routes (must be last)
  match '*unmatched', to: 'errors#not_found', via: :all, constraints: lambda { |req| !req.path.start_with?('/rails/active_storage') }

end
