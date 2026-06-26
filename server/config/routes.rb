Rails.application.routes.draw do
  get '/api-docs', to: 'api_docs#index'

  # Email confirmation + password reset — HTML pages opened in browser from email links
  get  '/confirm_email',  to: 'email_confirmations#confirm'
  get  '/reset_password', to: 'password_resets#new'
  post '/reset_password', to: 'password_resets#create'

  # Legacy (deprecated — kept for React frontend)
  root to: 'application#root'
  post '/oauth', to: 'auth#oauth'
  post '/users', to: 'users#create'
  get  '/me',    to: 'users#me'
  resources :goals, only: [:index, :create, :update, :destroy]

  # V1 — Evensong iOS API
  namespace :v1 do
    post  'oauth',                to: 'auth#oauth'
    post  'email_signup',         to: 'auth#email_signup'
    post  'email_signin',         to: 'auth#email_signin'
    get   'me',                   to: 'auth#me'
    patch 'me',                   to: 'auth#update_me'
    post  'forgot_password',      to: 'auth#forgot_password'
    post  'resend_confirmation',  to: 'auth#resend_confirmation'

    resources :projects, only: [:index, :create, :show, :update] do
      collection { post :reorder }
      member do
        post :archive
        post :unarchive
      end
      resources :milestones, only: [:index, :create, :update, :destroy]
    end

    resources :goals, only: [:index, :create, :update] do
      member do
        post :checkin
        post :carry_forward
      end
    end
  end
end
