Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '*',
      headers: :any,
      methods: %i[get post delete options],
      expose: %w[Content-Type],
      max_age: 600
  end
end
