Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users do
        resource :cart, only: [:show]
      end
      
      resources :products
      resources :cart_items

      # Rotas de carrinhos abandonados
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

  # Rota para visualizar emails em desenvolvimento (comentado temporariamente)
  # if Rails.env.development?
  #   mount LetterOpenerWeb::Engine, at: "/letter_opener"
  # end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end