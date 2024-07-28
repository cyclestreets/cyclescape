# frozen_string_literal: true

class UserLocationObserver < ActiveRecord::Observer
  def after_save(user_location)
    user = user_location.user
    if user.prefs.involve_my_locations == "subscribe"
      Issue.intersects(user_location.location).each do |issue|
        issue.threads.each do |thread|
          thread.add_subscriber(user) if MessageThreadPolicy.new(user, thread).show? && !user.ever_subscribed_to_thread?(thread)
        end
      end
    end
  end

  def after_destroy(user_location)
    user = user_location.user
    if user.prefs.involve_my_locations == "subscribe"
      Issue.intersects(user_location.location).each do |issue|
        issue.threads.each do |thread|
          next unless user.subscribed_to_thread?(thread)

          next if (user.prefs.involve_my_locations == "subscribe" &&
                   user.buffered_location &&
                   thread.issue.location.intersects?(user.buffered_location)
                  ) || (
                   thread.group&.members&.include?(user) &&
                   user.prefs.involve_my_groups == "subscribe"
                 )

          user.thread_subscriptions.to(thread).destroy
        end
      end
    end
  end
end
