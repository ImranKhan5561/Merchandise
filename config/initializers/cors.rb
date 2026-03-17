Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*' # Later change this to specific frontend URL like 'http://localhost:3000'
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization']
  end
end
