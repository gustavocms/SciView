SciView::Application.routes.draw do

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  namespace :ng do
    root 'base#home'
  end
  

  resources :charts, only: [:index, :show, :create] do
    collection do
      get :multiple
    end
  end

  resources :datasets, only: [:index, :show] do
    collection do
      get :multiple
      get :profile
      get :metadata
      get :status
    end

    resources :tags, only: [:create, :destroy]
    resources :attributes, only: [:create, :destroy]
  end

  resources :coffee_charts, only: [:show]

  resources :uploads, only: [:new, :create]

  devise_for :users
  get "d3/index"
  get 'data/:key' => 'data#show', :constraints => { :key => /([^\/])+?/, :format => false }
  get 'series/list' => 'data#list_series'
  get "d3/gf_style"


  #get "welcome/index"
  resources :posts
  root 'welcome#index'

  # JSON API for the angular app
  # (will eventually replace the datasets resource above)
  namespace :api do
    namespace :v1 do
      
      resource 's3_options'
      resources :datasets, only: [:show] do 
        collection do
          get :multiple
        end
      end

      resources :view_states

      resources :series
    end
  end
end
