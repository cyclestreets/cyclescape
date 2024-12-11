# frozen_string_literal: true

namespace :scheduled do
  task process_all_mailboxes: :environment do
    Rails.application.credentials.mail.each_value do |config|
      MailboxReader.new(config).run
    end
  end

  task new_planning_applications: :environment do
    PlanningApplicationWorker.new.process!
  end

  task remove_old_planning_applications: :environment do
    PlanningApplication.remove_old
  end

  task issue_upcoming_deadlines: :environment do
    Issue.email_upcomming_deadlines!
  end

  task upcoming_deadlines: :environment do
    DeadlineMessage.email_upcomming_deadlines!
  end

  task email_user_digests: :environment do
    User.email_digests!
  end

  task capture_query_stats: :environment do
    PgHero.capture_query_stats(verbose: false)
  end
end
