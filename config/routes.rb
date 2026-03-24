Rails.application.routes.draw do
  devise_for :users,
    path: "",
    path_names: {
      sign_in:  'api/v1/users/sign_in',
      sign_out: 'api/v1/users/sign_out',
      registration: 'api/v1/users'
    },
    controllers: {
      registrations: 'api/v1/registrations'
    }

  namespace :api do
    namespace :v1 do
      resources :users, except: [:create] do
        resource :cart, only: [:show] do
          member do
            post :checkout
          end
        end
      end

      resources :products
      resources :cart_items

      resources :abandoned_carts, only: [:index, :show] do
        member do
          post :recover
        end
        collection do
          get :stats
        end
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
