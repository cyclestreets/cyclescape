source 'http://rubygems.org'

gem 'rails', '~> 4.2.0'
gem 'pg'
gem 'activerecord-postgis-adapter'

# Only uncomment the debugger if you are using it as it slows things down
# gem 'ruby-debug19', require: 'ruby-debug'

# Front-end gems
gem 'jquery-rails', '~> 3.0.0'
gem 'haml-rails'
gem 'formtastic'
gem 'map_layers'
gem 'rails-jquery-autocomplete'
gem 'rgeo-geojson'
gem 'kaminari'
gem 'kaminari-i18n'
gem 'rails_autolink'
gem 'tweet-button'
gem 'chartkick'
# gem 'jquery-turbolinks'

# Back-end gems
gem 'devise', '~> 3.4.0'
gem 'devise_invitable'
gem 'devise-i18n'
gem 'declarative_authorization'
gem 'thin'
gem 'aasm'
gem 'rack-cache', require: 'rack/cache'
gem 'dragonfly', '~> 1.0.3'
gem 'redis-rails'
gem 'resque'
gem 'thumbs_up', '~> 0.4.6'
gem 'foreman'
gem 'whenever'
gem 'draper'
gem 'email_reply_parser'
gem 'actionview-encoded_mail_to'
gem 'memoist'
gem 'excon'
gem 'paranoia', '~> 2.0'
gem 'mustache'
gem 'icalendar'
gem 'attribute_normalizer'

gem 'grape', github: 'ruby-grape/grape'
gem 'grape-swagger'
gem 'grape-kaminari'

gem 'rack-cors', require: 'rack/cors'
gem 'rollbar'
gem 'rakismet'

gem 'sass-rails', '~> 5.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'compass-rails'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-ui-rails', '~> 5.0.0'
# gem 'turbolinks'
gem 'rails-observers'
gem 'rails-i18n', '~> 4.0.0'
gem 'will-paginate-i18n'
gem 'sunspot_solr', github: 'nikolai-b/sunspot', branch: 'bb_conjunctions'
gem 'sunspot_rails', github: 'nikolai-b/sunspot', branch: 'bb_conjunctions'
gem 'tagsinput-rails'

group :development do
  gem 'letter_opener'
  gem 'quiet_assets'
  gem 'annotate', '>= 2.5.0', require: false
  gem 'bullet'
  # Following is required for Resque workers in development to load due to
  # declarative_authorization development dependency when Rails engines are eager loaded
  gem 'ruby_parser'
end

group :development, :test do
  gem 'pry'
  gem 'rspec-rails'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'ruby-prof'
  gem 'parallel_tests'
  gem 'pry-rails'
  gem 'pry-byebug'
end

group :test do
  gem 'sunspot_test'
  gem 'rspec-collection_matchers'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'launchy'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'email_spec'
  gem 'database_cleaner'
  gem 'webmock'
end
