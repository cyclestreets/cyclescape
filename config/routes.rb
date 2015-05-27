Cyclescape::Application.routes.draw do

  # Pretty evil but beats copy pasting
  def issues_route(opts = {})
    resources :issues, opts do
      member do
        get 'geometry'
        put 'vote_up'
        put 'vote_down'
        put 'vote_clear'
      end
      collection do
        get 'all_geometries'
      end
      scope module: 'issue' do
        resource :photo, only: [:show]
        resources :threads, controller: 'message_threads'
        resource :tags, only: [:update]
      end
    end
  end

  devise_for :users, controllers: { confirmations: 'confirmations' }

  scope 'settings' do
    get '/edit', to: "user/profiles#edit", as: :current_user_profile_edit
    get '/preferences', to: "user/prefs#edit", as: :current_user_prefs_edit
    get '/location', to: "user/locations#index", as: :current_user_locations
    get '/', to: "user/profiles#show", as: :current_user_profile
  end

  constraints(SubdomainConstraint) do
    root to: 'groups#show'
    resources :threads, controller: 'group/message_threads'
    issues_route controller: 'group/issues'
  end

  resource :overview, as: :dashboard, controller: 'dashboards' do
    get 'search'
  end

  issues_route

  namespace :admin do
    resources :groups
    resources :users do
      scope module: 'user' do
        resources :locations do
          get 'geometry', on: :member
          get 'combined_geometry', on: :collection
        end
      end
    end
    match 'home' => 'home#index'
  end

  resources :groups do
    scope module: 'group' do
      resources :members
      resources :memberships
      resources :membership_requests do
        member do
          get 'review'
          post 'confirm'
          post 'reject'
          post 'cancel'
        end
      end
      resources :threads, controller: 'message_threads'
      resource :profile do
        get 'geometry', on: :member
      end
      resource :prefs, only: [:edit, :update]
    end
    collection do
      get 'all_geometries'
    end
  end

  resources :group_requests do
    member do
      get 'review'
      put 'confirm'
      put 'reject'
    end
  end

  resources :threads, controller: 'message_threads' do
    resources :messages do
      put 'censor', on: :member
      resources :documents, controller: 'message_library/documents'
      resources :notes, controller: 'message_library/notes'
    end
    scope module: :message do
      resources :photos, only: [:create, :show]
      resources :links, only: [:create]
      resources :street_views, only: [:create]
      resources :deadlines, only: [:create]
      resources :library_items, only: [:create]
      resources :documents, only: [:create, :show]
    end
    scope module: :message_thread do
      resources :subscriptions, only: [:create, :destroy]
      resource :tags, only: [:update]
      resource :user_priorities, only: [:create, :update]
    end
  end

  resource :library do
    get 'search'
    get 'recent'
    scope module: 'library' do
      resources :documents
      resources :notes
      resources :tags, only: [:update]
    end
  end

  resources :planning_applications do
    get :search, on: :collection
    get 'uid/*uid', to: :show_uid, on: :collection
    get :geometry, on: :member
    put :hide, on: :member
    put :unhide, on: :member
    scope module: "planning_application" do
      resource :issue
    end
  end

  resources :users do
    scope module: :user do
      resource :profile
      resource :prefs, only: [:edit, :update]
    end
  end

  namespace :user do
    resources :locations do
      get 'geometry', on: :member
      get 'combined_geometry', on: :collection
      post 'subscribe_to_threads', on: :collection
    end
  end

  namespace :site do
    resources :comments
  end

  resources :tags do
    get 'autocomplete_tag_name', as: :autocomplete, on: :collection
  end
  resource :home, only: [:show], controller: 'home'

  match 'template/:action', controller: 'home'
  match 'pages/:page', controller: 'pages', action: 'show', as: :page, via: :get

  root to: 'home#show'
end
