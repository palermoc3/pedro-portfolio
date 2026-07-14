Rails.application.routes.draw do
  root "home#index"

  get "/dashboard", to: "dashboard#index"
  get "/kpis.json", to: "kpis#show"

  namespace :api do
    resources :customers, only: :index
  end
end
