class MessageThreadObserver < ActiveRecord::Observer
  def after_save(thread)
    if thread.privacy_changed?
      case thread.privacy
      when "committee"
        thread.subscribers.each do |subscriber|
          subscriber.thread_subscriptions.to(thread).destroy unless thread.group.committee_members.include?(subscriber)
        end
      when "group"
        if thread.privacy_was == "public"
          thread.subscribers.each do |subscriber|
            subscriber.thread_subscriptions.to(thread).destroy unless thread.group.members.include?(subscriber)
          end
        elsif thread.privacy_was == "committee"
          ThreadSubscriber.subscribe_users(thread)
        end
      when "public"
        ThreadSubscriber.subscribe_users(thread)
      end
    end
  end
end
