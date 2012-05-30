Cyclescape::Application.routes.draw do
  # Pretty evil but beats copy pasting
  def issues_route(opts = {})
    resources :issues, opts do
      member do
        get "geometry"
        put "vote_up"
        put "vote_down"
        put "vote_clear"
      end
      collection do
        get "all_geometries"
        get "search"
      end
      scope module: "issue" do
        resource :photo, only: [:show]
        resources :threads, controller: "message_threads"
        resource :tags, only: [:update]
      end
    end
  end

  devise_for :users, :controllers => { :confirmations => "confirmations" }

  constraints(SubdomainConstraint) do
    root :to => "groups#show"
    resources :threads, controller: "group/message_threads"
    issues_route controller: "group/issues"
  end

  resource :overview, as: :dashboard, controller: "dashboards" do
    get 'search'
  end

  issues_route

  namespace :admin do
    resources :groups, :users
    match "home" => "home#index"
  end

  resources :groups do
    scope module: "group" do
      resources :members
      resources :memberships
      resources :membership_requests do
        member do
          post "confirm"
          post "reject"
          post "cancel"
        end
      end
      resources :threads, controller: "message_threads"
      resource :profile do
        get 'geometry', :on => :member
      end
    end
  end

  resources :threads, controller: "message_threads" do
    resources :messages do
      put 'censor', :on => :member
    end
    collection do
      get "search"
    end
    scope module: :message do
      resources :photos, only: [:create, :show]
      resources :links, only: [:create]
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
    scope module: "library" do
      resources :documents
      resources :notes
      resources :tags, only: [:update]
    end
  end

  resources :planning_applications do
    get 'geometry', :on => :member
    get 'convert', :on => :member
  end

  resources :users do
    scope module: :user do
      resource :profile
      resource :prefs, only: [:edit, :update]
    end
  end

  namespace :user do
    resources :locations do
      get 'geometry', :on => :member
      get 'combined_geometry', :on => :collection
    end
  end

  namespace :site do
    resources :comments
  end

  resources :tags
  resource :home, only: [:show], controller: "home"

  match "template/:action", controller: "home"
  match "pages/:page", controller: "pages", action: "show", as: :page, via: :get

  root :to => "home#show"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
