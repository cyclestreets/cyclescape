Rails.application.configure do
  config.eager_load = true
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_files = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  config.log_level = :info
  config.logger = Logger.new("#{Rails.root}/log/#{Rails.env}.log", 'weekly')

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Make sure appropriate pages are served over SSL
  if Rails.env.production?
    config.to_prepare { Devise::SessionsController.force_ssl only: [:new, :create] }
    config.to_prepare { Devise::RegistrationsController.force_ssl only: [:new, :create, :edit, :update] }
  end
end

Rails.application.config.middleware.use ExceptionNotification::Rack,
  :email => {
    :email_prefix => "[CS-Error] ",
    :sender_address => %{"notifier" <notifier@cyklistesobe.cz>},
    :exception_recipients => %w{petr.dlouhy@auto-mat.cz}
  }
