require 'rubygems'

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'email_spec'
require 'database_cleaner'
require 'declarative_authorization/maintenance'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true

  # Render views in controller tests
  config.render_views

  config.include Devise::TestHelpers, type: :controller
  config.include Authorization::TestHelper, type: :controller
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation, except: %w(geometry_columns spatial_ref_sys))

    # Clear out DragonFly assets
    dragonfly_path = "#{Rails.root}/public/system/dragonfly/test"
    FileUtils.rm_r(dragonfly_path) if File.exists?(dragonfly_path)

    # Create the root user
    unless User.where('id = 1').exists?
      root = User.new(email: 'root@cyclescape.org', full_name: 'Root',
                      password: 'changeme', password_confirmation: 'changeme')
      root.role = 'admin'
      root.skip_confirmation!
      root.save!
      User.update_all('id = 1', "id = #{root.id}")
    end

    # Disable the observers so that their behaviour can be tested independently
    ActiveRecord::Base.observers.disable :all

    FactoryGirl.reload
    # Reload translations
    I18n.reload!
  end

  config.before(:each) do
    DatabaseCleaner.start

    # Clear ActionMailer deliveries
    ActionMailer::Base.deliveries.clear
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.infer_spec_type_from_file_location!
end
