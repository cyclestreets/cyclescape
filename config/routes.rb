Cyclescape::Application.routes.draw do
  devise_for :users

  resource :dashboard

  resources :issues do
    get 'geometry', :on => :member
    get 'all_geometries', :on => :collection
    scope module: "issue" do
      resources :threads, controller: "message_threads"
    end
  end

  namespace :admin do
    resources :groups, :issue_categories, :users
    match "home" => "home#index"
  end

  resources :groups do
    scope module: "group" do
      resources :members
      resources :memberships
      resources :membership_requests do
        post 'confirm', :on => :member
        post 'reject', :on => :member
        post 'cancel', :on => :member
      end
      resources :threads, controller: "message_threads"
      resource :profile do
        get 'geometry', :on => :member
      end
    end
  end

  resources :threads, controller: "message_threads" do
    resources :messages
    scope module: :message do
      resources :photos, only: [:create]
      resources :links, only: [:create]
      resources :deadlines, only: [:create]
      resources :library_items, only: [:create]
    end
    scope module: :message_thread do
      resources :subscriptions, only: [:create, :destroy]
    end
  end

  resource :library do
    scope module: "library" do
      resource :search, only: [:new] do
        get :create, on: :collection
      end
      resources :documents
      resources :notes
    end
  end

  resources :users do
    scope module: :user do
      resource :profile
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
