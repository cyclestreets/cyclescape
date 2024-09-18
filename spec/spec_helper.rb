# frozen_string_literal: true

require "rubygems"

ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../config/environment", __dir__)
require "rspec/rails"
require "capybara/rspec"
require "email_spec"
require "database_cleaner"
require "webmock/rspec"
require "pundit/matchers"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
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

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include RSpec::Helpers::StubAkismet, type: :feature
  config.include WaitForAjax, type: :feature

  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction

    # Clear out DragonFly assets
    dragonfly_path = "#{Rails.root}/public/system/dragonfly/test"
    FileUtils.rm_r(dragonfly_path) if File.exist?(dragonfly_path)

    # Create the root user
    unless User.where(id: 1).exists?
      root = User.new(email: "root@cyclescape.org", full_name: "Root",
                      password: "changeme", password_confirmation: "changeme", role: "admin")
      root.skip_confirmation!
      root.save!
    end

    ActiveRecord::Base.connection.insert(
      "INSERT INTO html_issues (created_at) VALUES (CURRENT_TIMESTAMP)"
    )

    FactoryBot.create :site_config

    # Disable the observers so that their behaviour can be tested independently
    ActiveRecord::Base.observers.disable :all

    FactoryBot.reload
    # Reload translations
    I18n.reload!
  end

  config.around(:each) do |ex|
    DatabaseCleaner.strategy = :transaction
    truncate_clean = ex.metadata[:db_truncate] || ex.metadata[:js]
    if truncate_clean
      DatabaseCleaner.strategy = :truncation, {
        pre_count: true, cache_tables: true,
        except: %w[geometry_columns spatial_ref_sys site_configs html_issues]
      }
    end

    DatabaseCleaner.start

    # Clear ActionMailer deliveries
    ActionMailer::Base.deliveries.clear

    resque_inline = Resque.inline
    if ex.metadata[:solr]
      Resque.inline = true
      SunspotTest.unstub
    else
      SunspotTest.stub
    end

    default_host = Capybara.default_host
    Capybara.default_host = "http://localhost" if ex.metadata[:js]

    ex.run

    Capybara.default_host = default_host if ex.metadata[:js]

    Resque.inline = resque_inline
    DatabaseCleaner.clean

    FactoryBot.create(:site_config) unless SiteConfig.exists?

    if truncate_clean && User.where(id: 1).blank?
      root = User.new(email: "root@cyclescape.org", full_name: "Root",
                      password: "changeme", password_confirmation: "changeme", role: "admin")
      root.skip_confirmation!
      root.save!
      User.where(id: 1).update_all(id: root.id.to_s)
    end
  end

  # requires a running test solr env
  # $ RAILS_ENV=test rake sunspot:solr:start
  # then to run the solr specs
  # $ SOLR=1 be rspec --tag solr
  config.filter_run_excluding solr: true unless ENV["SOLR"]

  config.infer_spec_type_from_file_location!
  config.include FactoryBot::Syntax::Methods
  config.include AbstractController::Translation
  config.order = :random
end
