Rails.application.routes.draw do
  
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
 
  namespace :admin do
    root to: "dashboard#index"
    resources :orders, only: [:index, :show, :update]
    resources :categories
    resources :option_types
    resources :attachments, only: [:destroy]
    resources :products do
      resources :variants do
        collection do
          patch :update_visual_settings
          post :bulk_update_images
        end
      end
    end
  end

  namespace :api do
    resources :products, only: [:index, :show], param: :slug
    resources :categories, only: [:index]
    resource :cart, only: [:show] do
      post :add_item
      delete :remove_item
    end
    post 'auth/verify_otp', to: 'auth#verify_otp'
  end

end
