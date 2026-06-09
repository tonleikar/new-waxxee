Rails.application.routes.draw do
  devise_for :users

  root to: 'pages#home'

  resources :welcome, only: [:index]
  resources :users, only: [:index]
  resources :feed, only: [:index], controller: :followers
  resources :followers, only: %i[index create destroy]
  resources :collections, controller: :folders, only: %i[create destroy]
  resources :folder_vinyls, only: %i[create destroy]
  resources :personas, only: %i[create destroy]
  resources :swiper, only: [:index] do
    collection do
      post :card_preview
    end
  end
  get 'swiper/music_preview', to: 'swiper#music_preview'

  resources :profile, only: %i[show edit update destroy]
  resources :user_vinyls, only: %i[create destroy]
  resources :vinyls, only: %i[index show create]
  resources :discogs, only: %i[index create]
  resources :profile, only: %i[show edit update destroy] do
    patch :avatar, on: :member
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  #
end
