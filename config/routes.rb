Raclette::Application.routes.draw do
  get    'login',  :controller => :sessions, :action => :new
  post   'login',  :controller => :sessions, :action => :create
  get    'logout', :controller => :sessions, :action => :destroy
  delete 'logout', :controller => :sessions, :action => :destroy

  get 'monitor/overview'

  get 'register/choose_person'
  match 'register/member/:member_id/new_transaction' =>
          'register#new_member_transaction',
        :constraints => { :member_id => /\d+/ },
        :via         => :get
  match 'register/member/:member_id/create_entry' =>
          'register#create_member_entry',
        :constraints => { :member_id => /\d+/ },
        :via         => :post
  match 'register/member/:member_id/create_ticket_purchase' =>
          'register#create_member_ticket_purchase',
        :constraints => { :member_id => /\d+/ },
        :via         => :post
  match 'register/member/:member_id/create_membership_purchase' =>
          'register#create_member_membership_purchase',
        :constraints => { :member_id => /\d+/ },
        :via         => :post
  match 'register/guest/new_transaction' =>
          'register#new_guest_transaction',
        :via => :get
  match 'register/guest/create_entry' =>
          'register#create_guest_entry',
        :via => :post
  match 'register/guest/create_anonymous_entry' =>
          'register#create_anonymous_entry',
        :via => :post

  get 'secretary_tools/overview'
  get 'manager_tools/overview'

  resources :activity_periods
  resources :events
  resources :instructors
  resources :lesson_supervisions
  resources :members
  resources :membership_types

  resources :memberships do
    resources :ticket_books, :except => :index
  end

  resources :ticket_books, :only => :index

  resources :people, :only => [:index, :show]
  resources :weekly_events

  scope '/admin', :module => :admin do  # an alternative for admin namespace
  # namespace :admin do

    resources :users

    resources :known_ips, :controller => :known_i_ps

    resources :safe_user_ips, :controller => :safe_user_i_ps,
                              :only       => [:index] do
      collection do
        get 'edit_all', :action => :edit_all
        put '', :action => :update_all
      end
    end

    get 'admin_tools/overview'
  end

  root :to => 'monitor#overview'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
