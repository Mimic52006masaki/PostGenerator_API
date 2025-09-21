Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # 開発時の React URL
    origins '*'
    resource '*',
      headers: :any,
      methods: [:get, :post, :delete, :options]
  end
end
