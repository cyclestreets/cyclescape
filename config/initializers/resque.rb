require 'resque/server'
require 'resque/failure/multiple'
require 'resque/failure/redis'
require 'resque/rollbar'

Resque::Failure::Multiple.classes = [ Resque::Failure::Redis, Resque::Failure::Rollbar ]
Resque::Failure.backend = Resque::Failure::Multiple

Resque.redis.namespace = 'resque:Cyclescape'
Resque.inline = true if Rails.env.test?
Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
