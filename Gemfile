source 'http://rubygems.org'

gem 'rails', '3.1.1'
gem 'pg'
gem 'activerecord-postgis-adapter'

# Only uncomment the debugger if you are using it as it slows things down
# gem 'ruby-debug19', require: 'ruby-debug'

# Front-end gems
gem 'jquery-rails'
gem 'haml-rails'
gem 'formtastic'
gem 'map_layers'
gem 'rgeo-geojson', require: "rgeo/geo_json"

# Back-end gems
gem 'devise'
gem 'devise_invitable', "0.5.6"
gem 'declarative_authorization'
gem 'thin'
gem 'state_machine'
gem 'rack-cache', require: 'rack/cache'
gem 'dragonfly'
gem 'redis-store'
gem 'resque'
gem 'acts_as_indexed'
gem 'thumbs_up'
gem 'exceptional'
gem 'foreman'
gem 'whenever'
gem 'draper'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
  gem 'compass'
end

group :development do
  gem 'annotate', git: 'git://github.com/ctran/annotate_models.git', require: false

  # Following is required for Resque workers in development to load due to
  # declarative_authorization development dependency when Rails engines are eager loaded
  gem 'ruby_parser'
end

group :development, :test do
  # IRB helpers
  gem 'wirble'
  gem 'hirb'

  gem 'rspec-core'
  gem 'rspec-rails'
  gem 'spork', '~> 0.9.0.rc'
  gem 'ruby-prof'
end

group :test do
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'launchy'
  gem 'capybara'
  gem 'email_spec'
  gem 'database_cleaner'
  gem 'rspec-expectations'
end
