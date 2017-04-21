class ThreadAutoSubscriber
  class << self
    def queue
      :thread_views
    end

    def perform(thread_id, changes)
      thread = MessageThread.find(thread_id)
      thread.with_lock do
        if changes.keys.include?("privacy")
          case thread.privacy
          when 'committee'
            thread.subscribers.each do |subscriber|
              unless thread.group.committee_members.include?(subscriber)
                subscriber.thread_subscriptions.to(thread).destroy
                # TODO add removal notification
              end
            end
          when 'group'
            if changes["privacy"].first == 'public'
              thread.subscribers.each do |subscriber|
                unless thread.group.members.include?(subscriber)
                  subscriber.thread_subscriptions.to(thread).destroy
                  # TODO add removal notification
                end
              end
            elsif changes["privacy"].first == 'committee'
              ThreadSubscriber.subscribe_users(thread)
              # TODO add available notification for involvegroups / locations :notify
            end
          when 'public'
            ThreadSubscriber.subscribe_users(thread)
            # TODO add notification for involvegroups / locations :notify
          end
        end

        if changes.keys.include?("issue_id")
          if thread.issue
            ThreadSubscriber.subscribe_users(thread)
            # TODO notifications
          else
            thread.subscribers.each do |subscriber|
              unless thread.participants.include?(subscriber) || (thread.group && thread.group.members.include?(subscriber) && subscriber.prefs.involve_my_groups_admin)
                subscriber.thread_subscriptions.to(thread).destroy
                # TODO add removal notification
              end
            end
          end
        end
      end
    end
  end
end
