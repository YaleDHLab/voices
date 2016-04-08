VoicesRails::Application.routes.draw do
  resources :records

  # the application home page
  root "static_pages#home"
  
  # the user's home page
  get "user/show"

  # the application home page
  get "static_pages/home"

  # static about page
  get "static_pages/about"

  # static contact page
  get "static_pages/contact"

  get "user/logout"

  get "user/login"

  # support get request for email form fetch
  # and post for email form sbmission
  # and get for the confirmation
  get "contact_forms/new" => "contact_forms#new"
  post "contact_forms" => "contact_forms#create"

  # explicitly don't support get requests for contact_forms#show, 
  # as this view will be retired
  #get "contact_forms/:id" => "contact_forms#show"



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
