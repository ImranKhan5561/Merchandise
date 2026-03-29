Rails.application.routes.draw do
  root to: proc { [200, { "Content-Type" => "application/json" }, [{ status: "ok" }.to_json]] }
  
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
      patch :update_item
      delete :remove_item
    end
    post 'auth/verify_otp', to: 'auth#verify_otp'
    post 'auth/resend_otp', to: 'auth#resend_otp'
    get 'profile', to: 'profile#show'
    patch 'profile', to: 'profile#update'
    resources :addresses
    resources :orders, only: [:create, :index, :show] do
      patch :cancel, on: :member
    end
    resources :wishlist_items, only: [:index, :create, :destroy]
  end

end
