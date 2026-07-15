Rails.application.routes.draw do
  root "home#index"

  get "/dashboard", to: "dashboard#index"
  get "/dashboards/previsoes", to: "dashboards/predictions#index", as: :predictive_dashboard
  get "/kpis.json", to: "kpis#show"

  namespace :api do
    resources :customers, only: :index
    get "predictions", to: "predictions#show"
  end
end
