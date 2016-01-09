Rails.application.routes.draw do
  mount IssueApi::API => '/'

  # Pretty evil but beats copy pasting
  def issues_route(opts = {})
    resources :issues, opts do
      member do
        get :geometry
        put :vote_up, :vote_down, :vote_clear
      end
      get :all_geometries, on: :collection
      scope module: 'issue' do
        resource :photo, only: [:show]
        resources :threads, controller: 'message_threads'
        resource :tags, only: [:update]
      end
    end
  end

  devise_for :users, controllers: { confirmations: 'confirmations' }, skip: :registrations

  scope :settings do
    get :profile, to: "user/profiles#edit", as: :current_user_profile_edit
    get :preferences, to: "user/prefs#edit", as: :current_user_prefs_edit
    get :locations, to: "user/locations#index", as: :current_user_locations
    get '/', to: "user/profiles#show", as: :current_user_profile
  end
  devise_for :users, controllers: { registrations: 'users/registrations' }, only: :registrations, path: 'settings'

  constraints(SubdomainConstraint) do
    root to: 'groups#show', as: :subroot
    resources :threads, controller: 'group/message_threads'
    issues_route controller: 'group/issues'
    get 'overview/search', to: 'groups#search'
  end

  resource :overview, as: :dashboard, controller: 'dashboards' do
    get :search
  end
  get 'overview/:public_token/deadlines', to: 'dashboards#deadlines'

  issues_route

  namespace :admin do
    resources :groups
    resources :stats, only: :index
    resources :message_moderations, only: :index
    resources :users do
      put :approve, on: :member
      scope module: 'user' do
        resources :locations do
          get :geometry, on: :member
          get :combined_geometry, on: :collection
        end
      end
    end
    get 'home' => 'home#index'
  end

  resources :groups do
    scope module: :group do
      resources :members
      resources :memberships
      resources :message_moderations, only: [:index]
      resources :membership_requests do
        member do
          get :review
          post :confirm, :reject, :cancel
        end
      end
      resources :threads, controller: 'message_threads'
      resource :profile do
        get :geometry, on: :member
      end
      resource :prefs, only: [:edit, :update]
    end
    get :all_geometries, on: :collection
  end

  resources :group_requests do
    member do
      get :review
      put :confirm, :reject
    end
  end

  resources :threads, controller: 'message_threads' do
    put :open, :close, on: :member
    resources :messages do
      resources :documents, controller: 'message_library/documents'
      resources :notes, controller: 'message_library/notes'
      put :approve, :reject, :censor, on: :member
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
    get :search, :recent
    scope module: 'library' do
      resources :documents
      resources :notes
      resources :tags, only: [:update]
    end
  end

  resources :planning_applications do
    get :search, on: :collection
    get 'uid/*uid', action: :show_uid, on: :collection, as: :show_uid
    member do
      get :geometry
      put :hide, :unhide
    end
    scope module: :planning_application do
      resource :issue, only: :new
    end
  end

  resources :users, only: [] do
    scope module: :user do
      resource :profile
      resource :prefs, only: [:edit, :update]
    end
    resources :private_messages, only: [:new, :create, :index],
      controller: 'users/private_message_threads'
  end

  namespace :user do
    resources :locations do
      get :geometry, on: :member
      collection do
        get :combined_geometry
        post :subscribe_to_threads
      end
    end
  end

  namespace :site do
    resources :comments
  end

  resources :tags do
    get :autocomplete_tag_name, as: :autocomplete, on: :collection
  end
  resource :home, only: [:show], controller: 'home'

  get 'template/:action', controller: 'home'
  get 'pages/:page', controller: 'pages', action: 'show', as: :page

  root to: 'home#show'

  resque_constraint = lambda do |request|
    request.env['warden'].authenticate? and request.env['warden'].user.role == 'admin'
  end

  constraints resque_constraint do
    mount Resque::Server, at: "/admin/resque"
  end
end
