# frozen_string_literal: true

class ThreadAutoSubscriber
  extend Resque::Plugins::ExponentialBackoff
  @retry_limit = 3

  class << self
    def queue
      :medium
    end

    def perform(thread_id, changes)
      return if changes.keys.include?("deleted_at")

      thread = MessageThread.find(thread_id)

      only_one(thread_id, changes) do
        if changes.keys.include?("privacy")
          case thread.privacy
          when "committee"
            thread.subscribers.each do |subscriber|
              unless thread.group.committee_members.include?(subscriber)
                subscriber.thread_subscriptions.to(thread).destroy
                # TODO: add removal notification
              end
            end
          when "group"
            if changes["privacy"].first == "public"
              thread.subscribers.each do |subscriber|
                unless thread.group.members.include?(subscriber)
                  subscriber.thread_subscriptions.to(thread).destroy
                  # TODO: add removal notification
                end
              end
            elsif changes["privacy"].first == "committee"
              ThreadSubscriber.subscribe_users(thread)
              # TODO: add available notification for involvegroups / locations :notify
            end
          when "public"
            ThreadSubscriber.subscribe_users(thread)
            # TODO: add notification for involvegroups / locations :notify
          end
        end

        if changes.keys.include?("issue_id")
          if thread.issue
            ThreadSubscriber.subscribe_users(thread)
            # TODO: notifications
          else
            thread.subscribers.each do |subscriber|
              unless thread.participants.include?(subscriber) || (thread.group&.members&.include?(subscriber) && subscriber.prefs.involve_my_groups_admin)
                subscriber.thread_subscriptions.to(thread).destroy
                # TODO: add removal notification
              end
            end
          end
        end
      end
    end

    def only_one(id, changes)
      r = Thread.current[:redis] || Redis.new
      redis_key = ["tas", "threadid", id].join(":")

      unless r.set(redis_key, 1, ex: 5, nx: true)
        sleep 1
        Rollbar.info("Thread subscriber called twice", id: id, changes: changes)
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
