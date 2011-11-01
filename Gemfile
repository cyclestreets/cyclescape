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
gem 'devise_invitable'
gem 'declarative_authorization'
gem 'thin'
gem 'state_machine'
gem 'rack-cache', require: 'rack/cache'
gem 'dragonfly'
gem 'acts_as_indexed'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
# gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

group :development do
  gem 'annotate', git: 'git://github.com/ctran/annotate_models.git', require: false
end

group :development, :test do
  # IRB helpers
  gem 'wirble'
  gem 'hirb'

  gem 'rspec-core'
  gem 'rspec-rails'
  gem 'spork', '~> 0.9.0.rc'
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
