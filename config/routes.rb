VoicesRails::Application.routes.draw do
  resources :records

  # the application home page
  root "static_pages#home"
  
  # the user's home page
  get "user/show"

  # the application home page
  get "static_pages/home"

  # static about page
  get "about" => "static_pages#about"

  # static contact page
  get "static_pages/contact"

  # login / logout pages
  get "user/logout"
  get "user/login"

  # support get request for email form fetch
  # and post for email form sbmission
  # and get for the confirmation
  get "contact" => "contact_forms#new", as: :contact_forms
  post "contact" => "contact_forms#create"

  # angular search page
  get "user/angular_show" => "user#angular_show"

  # expose endpoint for creation of new record_attachments
  post "record_attachments" => "record_attachments#create"

  # expose update method for record_attachments so users can annotate
  put "record_attachments/:id" => "record_attachments#update_annotation"

  # expose get method for annotate page (only shown on multiple attachment records)
  get "annotate/:id" => "records#annotate"

  # expose a method for deleting record attachments
  delete "record_attachments/:id" => "record_attachments#destroy"


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
