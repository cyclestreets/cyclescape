# frozen_string_literal: true

Rails.application.routes.draw do
  mount Api => "/"
  mount GrapeSwaggerRails::Engine => "/api"

  # Pretty evil but beats copy pasting
  def issues_route(opts = {})
    resources :issues, opts do
      member do
        get :geometry
        put :vote_up, :vote_clear
      end
      collection do
        post :vote_detail
      end
      get :all_geometries, on: :collection
      scope module: "issue" do
        resource :photo, only: [:show]
        resources :threads, controller: "message_threads"
        resource :tags, only: [:update]
      end
    end
  end

  devise_for(
    :users, skip: :registrations,
    controllers: { confirmations: "confirmations", omniauth_callbacks: 'users/omniauth_callbacks' }
  )
  scope :settings do
    get :profile, to: "user/profiles#edit", as: :current_user_profile_edit
    get :preferences, to: "user/prefs#edit", as: :current_user_prefs_edit
    get :locations, to: "user/locations#index", as: :current_user_locations
    get "/", to: "user/profiles#show", as: :current_user_profile
  end
  devise_for :users, controllers: { registrations: "users/registrations" }, only: :registrations, path: "settings"

  constraints(SubdomainConstraint) do
    root to: "groups#show", as: :subroot
    resources :threads, controller: "group/message_threads"
    issues_route controller: "group/issues"
    get "overview/search", to: "groups#search"
    resources :hashtags, only: %i[index show], param: :name, controller: "group/hashtags"
  end

  get "private_messages", to: "private_messages#index"

  resource :user_blocks, only: %i[create destroy]

  resource :overview, as: :dashboard, controller: "dashboards" do
    get :search
  end
  get "overview/:public_token/deadlines", to: "dashboards#deadlines"

  issues_route

  namespace :new_ui do
    resources :groups, only: :show
    resources :issues, only: :index
    resource :user_favourites, only: %i[create destroy]
  end

  namespace :admin do
    get "templates/:template", to: "templates#show", as: :template
    resources :groups do
      put :disable, :enable, on: :member
    end
    resource :site_config
    resources :stats, only: :index do
      get :issues_untagged, on: :collection
      get :issues_with_multiple_threads, on: :collection
    end
    resources :message_moderations, only: :index
    resources :planning_filters
    resources :users do
      put :approve, on: :member
      scope module: "user" do
        resources :locations do
          get :geometry, on: :member
          get :combined_geometry, on: :collection
        end
      end
    end
    get "home" => "home#index"
  end

  resources :groups do
    scope module: :group do
      resources :members
      resources :potential_members, only: %i[new create]
      resources :memberships
      resources :message_moderations, only: [:index]
      resources :membership_requests do
        member do
          get :review
          post :confirm, :reject, :cancel
        end
      end
      resources :threads, controller: "message_threads"
      resource :profile do
        get :geometry, on: :member
      end
      resource :prefs, only: %i[edit update]
    end
    get :all_geometries, on: :collection
  end

  resources :group_requests do
    member do
      get :review
      put :confirm, :reject
    end
  end

  resources :threads, controller: "message_threads" do
    member do
      put :open, :close
      post :vote_detail
    end
    resources :messages do
      resources :documents, controller: "message_library/documents"
      resources :notes, controller: "message_library/notes", only: %i[new create show edit update destroy]
      member do
        put :approve, :reject, :censor, :vote_up, :vote_clear
      end
    end
    scope module: :message do
      resources :photos, only: %i[show]
      resources :cyclestreets_photos, only: %i[show]
      resources :library_items, only: [:create]
      resources :documents, only: %i[show]
      resources :polls, only: [] do
        put :vote, on: :member
      end
    end

    scope module: :message_thread do
      resources :subscriptions, only: %i[edit create destroy]
      resource :tags, only: [:update]
      resource :user_favourites, only: %i[create destroy]
      resource :leaders, only: %i[create destroy]
    end
  end

  resource :library do
    get :search, :relevant
    scope module: "library" do
      resources :documents
      resources :notes, only: %i[new create show edit update destroy]
      resources :tags, only: [:update]
    end
  end

  resources :planning_applications do
    get :search, on: :collection
    get "uid/:authority_param/*uid", action: :show_uid, on: :collection, as: :show_uid
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
      resource :prefs, only: %i[edit update]
    end
    resources :private_messages, only: %i[new create index],
                                 controller: "users/private_message_threads"
  end

  namespace :user do
    resources :locations do
      get :geometry, on: :member
      collection do
        get :combined_geometry
      end
    end
  end

  namespace :site do
    resources :comments
  end

  resources :tags, only: %i[show index] do
    get :autocomplete_tag_name, as: :autocomplete, on: :collection
    get :all_geometries, on: :member
  end
  resource :home, only: [:show], controller: "home"

  get "pages/:page", to: "pages#show", as: :page

  root to: "home#show"

  authenticate :user, ->(user) { user.admin? } do
    mount PgHero::Engine, at: "admin/pghero"
    mount Resque::Server, at: "admin/resque"
  end
end
