require File.expand_path('../boot', __FILE__)

require 'rails/all'
require "English"

Bundler.require(*Rails.groups)

module Cyclescape
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.action_view.sanitized_allowed_tags = %w[p br]
    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W(#{config.root}/app/models/messages)
    config.autoload_paths += %W(#{config.root}/app/models/validators)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]
    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    config.active_record.observers = :group_membership_observer, :user_location_observer, :user_pref_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    config.i18n.available_locales = %w(en-GB de-DE cs-CZ cs it)
    config.i18n.enforce_available_locales = true

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = 'en-GB'

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    config.assets.paths << "node_modules"

    # Set cache storage
    config.cache_store = :redis_store, "redis://localhost:6379/1",  { expires_in: 1.week }

    # ActionMailer default URL options
    config.action_mailer.default_url_options = { host: 'www.cyclescape.org' }

    # Git info
    config.git_hash = `git rev-parse --short HEAD`.chomp
    config.github_project_url = 'https://github.com/cyclestreets/cyclescape'

    # Planning applications
    config.planning_applications_url = "http://www.planit.org.uk/find/applics/json"

    # Active Job
    config.active_job.queue_adapter = :resque

    # Specify the file paths that should be browserified. We browserify everything that
    # matches (===) one of the paths. So you will most likely put lambdas
    # regexes in here.
    #
    # By default only files in /app and /node_modules are browserified,
    # vendor stuff is normally not made for browserification and may stop
    # working.
    config.browserify_rails.paths << /vendor\/assets\/javascripts\/module\.js/

    # Environments in which to generate source maps
    #
    # The default is none
    config.browserify_rails.source_map_environments << "development"

    # Should the node_modules directory be evaluated for changes on page load
    #
    # The default is `false`
    # config.browserify_rails.evaluate_node_modules = true

    # Force browserify on every found JavaScript asset if true.
    # Can be a proc.
    #
    # The default is `false`
    # config.browserify_rails.force = ->(file) { File.extname(file) == ".ts" }

    # Command line options used when running browserify
    #
    # can be provided as a string:
    config.browserify_rails.commandline_options = "-t coffeeify --extension=\".js.coffee\""

    # Define NODE_ENV to be used with envify
    #
    # defaults to Rails.env
    # config.browserify_rails.node_env = "production"
  end
end
