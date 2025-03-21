# frozen_string_literal: true

require_relative "boot"

require "rails/all"
require "English"
require File.expand_path(File.join("..", "..", "lib", "subdomain_constraint"), __FILE__)

Bundler.require(*Rails.groups)

module Cyclescape
  class Application < Rails::Application
    config.load_defaults 7.0
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.action_view.sanitized_allowed_tags = %w[p br ul ol li em strong table tbody thead tr td a blockquote]
    config.action_view.sanitized_allowed_attributes = %w[href title]
    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W[#{config.root}/app/models/messages]
    config.autoload_paths += %W[#{config.root}/app/models/validators]
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.eager_load_paths += %W[#{config.root}/app/models/messages]
    config.eager_load_paths += %W[#{config.root}/app/models/validators]
    config.eager_load_paths += Dir["#{config.root}/lib/**/"]

    config.paths.add File.join("app", "api"), glob: File.join("**", "*.rb")
    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    config.active_record.observers = :group_membership_observer, :user_location_observer, :user_pref_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    config.i18n.available_locales = %w[en-GB de-DE cs-CZ cs it en]
    config.i18n.enforce_available_locales = true

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = "en-GB"
    config.i18n.fallbacks = [I18n.default_locale, { "en-GB" => ["en-GB", :en] }]

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += %i[password password_confirmation]

    # Enable the asset pipeline
    config.assets.enabled = true
    config.tinymce.install = :compile

    # Version of your assets, change this if you want to expire all your assets
    config.assets.paths << "node_modules"

    config.assets.configure do |env|
      env.export_concurrent = false
    end
    # Set cache storage
    config.cache_store = :redis_cache_store, { url: "redis://localhost:6379/1", expires_in: 1.week, compress: true, namespace: "cs" }

    # When https://github.com/rails/rails/pull/45680 we can set the hosts but the feature is a bit too broken for us.
    config.action_controller.raise_on_open_redirects = false
    # config.hosts << '*.cyclescape.org'
    # config.hosts << ->(host) {
    #   @urls ||= begin
    #     url_helpers = Rails.application.routes.url_helpers
    #     [URI(url_helpers.root_url).host] +
    #       Group.pluck(:short_name).map do |subdomain|
    #         URI(url_helpers.root_url(subdomain: SubdomainConstraint.subdomain(subdomain))).host
    #       end
    #   end
    #   @urls.include?(host)
    # }

    # ActionMailer default URL options
    # To set the URL set the ENV["SERVER_NAME"].  The SubdomainConstraint adds the staging subdomain.
    config.action_mailer.default_url_options = { host: "#{::SubdomainConstraint.subdomain('www')}.#{ENV.fetch('SERVER_NAME', 'cyclescape.org')}" }

    # Git info
    config.git_hash = `git rev-parse --short HEAD`.chomp
    config.github_project_url = "https://github.com/cyclestreets/cyclescape"

    # Planning applications
    config.planning_applications_url = "https://www.planit.org.uk/api/applics/json"
    config.planning_areas_url = "https://www.planit.org.uk/api/areas/json"

    # Active Job
    config.active_job.queue_adapter = :resque

    # Specify the file paths that should be browserified. We browserify everything that
    # matches (===) one of the paths. So you will most likely put lambdas
    # regexes in here.
    #
    # By default only files in /app and /node_modules are browserified,
    # vendor stuff is normally not made for browserification and may stop
    # working.
    config.browserify_rails.paths << %r{vendor/assets/javascripts/module\.js}

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
    config.browserify_rails.commandline_options = "-t [ babelify --global --presets [ @babel/preset-env ] --plugins [ @babel/plugin-transform-modules-commonjs ] --sourceType unambiguous  ]"

    # Define NODE_ENV to be used with envify
    #
    # defaults to Rails.env
    # config.browserify_rails.node_env = "production"
    config.action_mailer.preview_paths << Rails.root.join("app", "controllers", "admin", "mailers")
    config.action_mailer.show_previews = true

    Rails::MailersController.include Rails.application.routes.url_helpers
    Rails::MailersController.prepend_before_action do
      authenticate_user!
      head :forbidden unless current_user.admin?
    end

    config.middleware.insert 0, Rack::UTF8Sanitizer # fix ArgumentError invalid %-encoding bugs, https://gist.github.com/bf4/d26259acfa29f3b9882b#file-exception_app-rb
  end
end
