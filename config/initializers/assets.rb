# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.1"

Rails.application.config.assets.configure do |env|
  env.export_concurrent = false
end
# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w[*.png *.jpg *.jpeg *.gif ie7.css street_view.js chartkick.js]
