Rails.application.routes.draw do
  scope :api do
    post '/scrape', to: 'scrapes#create'

    resources :posts, only: %i[index show destroy] do
      resources :details, only: [:index], module: :api
    end
  end
end
