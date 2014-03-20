Resque.redis.namespace = 'resque:Cyclescape'
Resque.inline = true if Rails.env.test?

# This seems to be required so that prepared statements don't fail due to
# attempting to be created on the second run of a job.
# https://github.com/defunkt/resque/issues/306#issuecomment-1421034
Resque.before_fork = proc { ActiveRecord::Base.establish_connection }
