# frozen_string_literal: true

source "http://rubygems.org"

gem "activerecord-postgis-adapter"
gem "pg"
gem "rails", "= 5.1.7"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end
# Only uncomment the debugger if you are using it as it slows things down
# gem 'ruby-debug19', require: 'ruby-debug'

# Front-end gems
gem "browserify-rails"
gem "chartkick"
gem "formtastic"
gem "haml-rails"
gem "jqcloud-rails", github: "GovSciences/jqcloud-rails"
gem "jquery-rails", "~> 4.1.1"
gem "kaminari"
gem "kaminari-i18n"
gem "leaflet-rails", "= 0.7.7"
gem "map_layers"
gem "rails-jquery-autocomplete"
gem "rails_autolink"
gem "ratelimit"
gem "retryable"
gem "rgeo-geojson"
# gem 'jquery-turbolinks'
gem "tinymce-rails"

# Back-end gems
gem "aasm"
gem "actionview-encoded_mail_to"
gem "attribute_normalizer"
gem "declarative_authorization", github: "xymist/declarative_authorization", branch: "allow_rails_5"
gem "devise"
gem "devise-i18n", "< 1.5" # Bug in devise-i18n 1.5, fixed if we bump devise > 4.4 https://github.com/tigrish/devise-i18n/blob/v1.5.0/rails/locales/en-GB.yml#L43
gem "devise_invitable"
gem "dragonfly"
gem "draper"
gem "email_reply_parser"
gem "excon"
gem "font-awesome-rails"
gem "foreman"
gem "html2text"
gem "http_accept_language"
gem "icalendar"
gem "mustache"
gem "paranoia", "~> 2.0"
gem "rack-cache", require: "rack/cache"
gem "redis-rails"
gem "resque"
gem "resque-rollbar"
gem "thin"
gem "thumbs_up", "~> 0.4.6"
gem "whenever"

gem "grape"
gem "grape-kaminari"
gem "grape-swagger"
gem "grape-swagger-rails"
gem "kaminari-grape"

gem "rack-cors", require: "rack/cors"
gem "rakismet"
gem "rollbar"

gem "coffee-rails"
gem "compass-rails", "> 3"
gem "jquery-ui-rails", "~> 5.0.0"
gem "sass-rails"
# gem 'turbolinks'
gem "lograge"
gem "nokogiri"
gem "progress_bar"
gem "rails-i18n"
gem "rails-observers"
gem "sunspot_rails", github: "sunspot/sunspot"
gem "sunspot_solr", github: "sunspot/sunspot"
gem "tagsinput-rails"
gem "uglifier", ">= 1.3.0"
gem "will-paginate-i18n"

group :staging do
  gem "sanitize_email"
end

group :development do
  gem "annotate", ">= 2.5.0", require: false
  gem "bullet"
  gem "letter_opener"
  gem "rubocop"
  gem "rubocop-rails"
  gem "rubocop-rspec"
  # Following is required for Resque workers in development to load due to
  # declarative_authorization development dependency when Rails engines are eager loaded
  gem "ruby_parser"

  # For memory profiling
  gem "rack-mini-profiler", require: false

  gem "memory_profiler"

  # For call-stack profiling flamegraphs
  gem "flamegraph"
  gem "stackprof"
end

group :development, :test do
  gem "parallel_tests"
  gem "pry"
  gem "pry-byebug"
  gem "pry-rails"
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
  gem "rails-controller-testing"
  gem "rspec-collection_matchers"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "sunspot_test"
  gem "webmock"
end
