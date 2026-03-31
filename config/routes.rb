Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "coffee_shops/nearest", to: "coffee_shops#nearest"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
