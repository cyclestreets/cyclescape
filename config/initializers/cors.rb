require 'rack/cors'

module Cyclescape
  class Application < Rails::Application
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '/api/*', headers: :any, methods: [:get, :post, :options], credentials: false
      end
    end
  end
end
