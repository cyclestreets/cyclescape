# frozen_string_literal: true

require "dragonfly"

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  secret "67428bd796e0a66ba924ae23f736897ccf44bcedb5ebb6f71ee6a33fa5ee2c46"

  url_format "/media/:job/:name"

  datastore :file,
            root_path: Rails.root.join("public/system/dragonfly", Rails.env),
            server_root: Rails.root.join("public")
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
ActiveSupport.on_load(:active_record) do
  extend Dragonfly::Model
  extend Dragonfly::Model::Validations
end
