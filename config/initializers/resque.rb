# frozen_string_literal: true

require "resque-retry"
require "resque-retry/server"
require "resque/failure/redis"

# Enable resque-retry failure backend.
Resque::Failure::MultipleWithRetrySuppression.classes = [Resque::Failure::Redis]
Resque::Failure.backend = Resque::Failure::MultipleWithRetrySuppression

Resque.redis.namespace = "resque:Cyclescape"
Resque.inline = true if Rails.env.test?

Resque.after_fork do
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end

Resque.before_fork do
  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!
end

module ActionMailer
  class DeliveryJob
    retry_on StandardError, wait: :exponentially_longer, attempts: 5
  end
end

module ActiveJob
  class Base
    retry_on StandardError, wait: :exponentially_longer, attempts: 5
  end
end
