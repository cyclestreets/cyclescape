# frozen_string_literal: true

source "https://rubygems.org"

gem "activerecord-postgis-adapter"
gem "pg"
gem "rails", "~> 7.2"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end
# Only uncomment the debugger if you are using it as it slows things down
# gem 'ruby-debug19', require: 'ruby-debug'

# Front-end gems
gem "bootstrap"
gem "browserify-rails"
gem "chartkick"
gem "cocoon"
gem "formtastic"
gem "haml-rails"
gem "jqcloud-rails", github: "GovSciences/jqcloud-rails"
gem "jquery-rails", "~> 4.4.0"
gem "kaminari"
gem "kaminari-i18n"
gem "leaflet-rails", "= 0.7.7"
gem "map_layers"
gem "rails_autolink"
gem "ratelimit"
gem "redis"
gem "retryable"
gem "rgeo"
gem "rgeo-geojson"
# gem 'jquery-turbolinks'
gem "tinymce-rails", "< 6" # Get Promise.allSettled in JS specs

# Back-end gems
gem "aasm"
gem "actionview-encoded_mail_to"
gem "devise"
gem "devise-i18n", "< 1.5" # Bug in devise-i18n 1.5, fixed if we bump devise > 4.4 https://github.com/tigrish/devise-i18n/blob/v1.5.0/rails/locales/en-GB.yml#L43
gem "devise_invitable"
gem "dragonfly"
gem "draper"
gem "email_reply_parser"
gem "excon"
gem "font-awesome-rails"
gem "foreman"
gem "hotwire-rails"
gem "html2text"
gem "http_accept_language"
gem "icalendar"
gem "mustache"
gem "net-http" # https://github.com/ruby/net-imap/issues/16
gem "normalizr"
gem "omniauth"
gem "omniauth-facebook"
gem "omniauth-rails_csrf_protection"
gem "omniauth-twitter"
gem "paranoia"
gem "pg_query"
gem "pghero"
gem "pundit"
gem "rack-cache", require: "rack/cache"
gem "rack-utf8_sanitizer"
gem "resque"
gem "resque-retry"
gem "resque-rollbar"
gem "sprockets-rails"
gem "thin"
gem "thumbs_up"
gem "whenever"

gem "grape"
gem "grape-kaminari"
gem "grape-swagger"
gem "grape-swagger-rails"
gem "kaminari-grape"

gem "cgi", ">= 0.3.6", require: false
gem "rack-cors", require: "rack/cors"
gem "rakismet"
gem "rollbar"

gem "jquery-ui-rails", "~> 5.0.0"
gem "sassc-rails"
gem 'turbo-rails'
gem "lograge"
gem "nokogiri"
gem "progress_bar"
gem "rails-i18n"
gem "rails-observers"
gem "sunspot_rails"
gem "sunspot_solr"
gem "tagsinput-rails"
gem "uglifier", ">= 1.3.0"
gem "will-paginate-i18n"

group :staging do
  gem "sanitize_email"
end

group :development do
  gem "annotate", require: false
  gem "better_errors"
  gem "bullet"
  gem "letter_opener"
  gem "rubocop"
  gem "rubocop-rails"
  gem "rubocop-rspec"

  # For memory profiling
  gem "rack-mini-profiler"

  gem "memory_profiler"

  # For call-stack profiling flamegraphs
  gem "flamegraph"
  gem "stackprof"
end

group :development, :test do
  gem "parallel_tests"
  gem "rspec-rails"
  gem "ruby-prof"
  gem "spring"
  gem "spring-commands-rspec"
end

group :test do
  gem "capybara"
  gem "database_cleaner"
  gem "email_spec"
  gem "factory_bot_rails"
  gem "launchy"
  gem "pundit-matchers"
  gem "rails-controller-testing"
  gem "rspec-collection_matchers"
  gem "selenium-webdriver"
  gem "shoulda-matchers", "< 6" # v6 adds normalize matcher which clashes with normalizr TODO: move to ActiveRecord::Base::normalizes API.
  gem "sunspot_test"
  gem "webmock"
  gem "webrick"
end
