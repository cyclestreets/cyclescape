require 'resque/server'
Resque.redis.namespace = 'resque:Cyclescape'
Resque.inline = true if Rails.env.test?
Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
