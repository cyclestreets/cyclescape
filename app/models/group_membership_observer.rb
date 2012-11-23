class GroupMembershipObserver < ActiveRecord::Observer
  def after_save(group_membership)
    if group_membership.role_changed?

      user = group_membership.user
      group = group_membership.group

      # Subscribe new committee members to committee threads, if appropriate
      if group_membership.role == "committee"

        if user.prefs.involve_my_groups == "subscribe"
          group.threads.where(privacy: "committee").each do |thread|
            thread.add_subscriber(user)
          end
        end
      end

      # Remove ex-committee members from committee threads
      if group_membership.role == "member" && group_membership.role_was == "committee"
        group.threads.where(privacy: "committee").each do |thread|
          subscription = user.thread_subscriptions.to(thread)
          subscription.destroy if subscription
        end
      end
    end
  end
end
