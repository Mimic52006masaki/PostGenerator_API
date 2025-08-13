Rails.application.routes.draw do
  scope :api do
    post   '/scrape', to: 'scrapes#create'
    resources :posts, only: %i[index show destroy]
  end
end
