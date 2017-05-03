class ThreadAutoSubscriber
  class << self
    def queue
      :thread_views
    end

    def perform(thread_id, changes)
      return if changes.keys.include?("deleted_at")
      thread = MessageThread.find(thread_id)


      only_one(thread_id, changes) do
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

    def only_one(id, changes)
      r = Redis.current
      redis_key = ["tas", "threadid", id].join(":")

      unless r.set(redis_key, 1, ex: 5, nx: true)
        sleep 3
        return Resque.enqueue(ThreadAutoSubscriber, id, changes)
      end

      begin
        yield
      ensure
        r.del(redis_key)
      end
    end
  end
end
