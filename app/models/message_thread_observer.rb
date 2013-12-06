class MessageThreadObserver < ActiveRecord::Observer
  def after_save(thread)
    if thread.privacy_changed?
      case thread.privacy
      when "committee"
        thread.subscribers.each do |subscriber|
          unless thread.group.committee_members.include?(subscriber)
            subscriber.thread_subscriptions.to(thread).destroy
            # TODO add removal notification
          end
        end
      when "group"
        if thread.privacy_was == "public"
          thread.subscribers.each do |subscriber|
            unless thread.group.members.include?(subscriber)
              subscriber.thread_subscriptions.to(thread).destroy
              # TODO add removal notification
            end
          end
        elsif thread.privacy_was == "committee"
          ThreadSubscriber.subscribe_users(thread)
          # TODO add available notification for involvegroups / locations :notify
        end
      when "public"
        ThreadSubscriber.subscribe_users(thread)
        # TODO add notification for involvegroups / locations :notify
      end
    end
  end
end
