source 'http://rubygems.org'

gem 'rails', '3.1.0'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'pg'

# Front-end gems
gem 'haml-rails'
gem 'formtastic'
gem 'map_layers', :git => "git@github.com:gravitystorm/map_layers.git", :branch => "toolkit"
gem 'rgeo-geojson'

# Back-end gems
gem 'devise'
gem 'activerecord-postgis-adapter'
gem 'devise_invitable'
gem 'declarative_authorization'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
# gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

gem 'jquery-rails'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :development, :test do
  # IRB helpers
  gem 'wirble'
  gem 'hirb'
  gem 'rspec-core'
  gem 'rspec-expectations'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'email_spec'
  gem 'database_cleaner'
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'launchy'
end
