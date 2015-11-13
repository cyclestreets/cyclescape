# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every 5.minutes do
  runner 'MailboxReader.process_all_mailboxes'
  env :MAILTO, 'cyclescape-errors@cyclestreets.net'
end

# This pulls in application from 5 days ago to 12 days ago (i.e. a weeks worth)
# They will be sorted with the oldest first.
# It looks like some Local Authorities (LAs) take a week or more to put the applications on-line.
# There is plenty of redudancy in this system but it balances getting up-to-date
# applications against missing applications from slow LAs.
# It will update the application if it already exists.
# PlanIt limit the results to 500.
#
# To get the past 6 months run this
# (1..180).step(15).each {|n_day| PlanningApplicationWorker.new(n_day.days.ago.to_date).process! }
every 1.day, at: '1:02 am' do
  runner "PlanningApplicationWorker.new.process!"
  env :MAILTO, 'cyclescape-errors@cyclestreets.net'
end

every 1.day, at: '2:02 am' do
  runner "PlanningApplication.remove_old"
  env :MAILTO, 'cyclescape-errors@cyclestreets.net'
end

every 1.day, at: '6:55 am' do
  runner "Issue.email_upcomming_deadlines!"
  env :MAILTO, 'cyclescape-errors@cyclestreets.net'
end

every 1.day, at: '7:05 am' do
  runner "DeadlineMessage.email_upcomming_deadlines!"
  env :MAILTO, 'cyclescape-errors@cyclestreets.net'
end
