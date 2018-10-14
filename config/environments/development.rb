Rails.application.configure do
  config.eager_load = false
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Use letter opener
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.default_url_options = { host: 'localhost:3000' }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # Generators config
  config.generators do |g|
    g.assets false
    g.helper false
    g.javascripts false
    g.stylesheets false
  end

  # If you want to avoid falling back to en-GB translations (i.e. you want
  # all missing translations in your language to throw errors) then set this
  # to `false`
  config.i18n.fallbacks = true

  config.action_view.raise_on_missing_translations = true
  config.assets.raise_runtime_errors = true
  config.active_record.raise_in_transactional_callbacks = true
end
