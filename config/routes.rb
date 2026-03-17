Rails.application.routes.draw do
  
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
 
  namespace :admin do
    root to: "dashboard#index"
    resources :categories
    resources :option_types
    resources :attachments, only: [:destroy]
    resources :products do
      resources :variant_image_sets, only: [:create, :update, :destroy]
      resources :variants do
        collection do
          patch :update_visual_settings
        end
      end
    end
  end
   
end
