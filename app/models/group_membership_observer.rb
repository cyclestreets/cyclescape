# frozen_string_literal: true

class GroupMembershipObserver < ActiveRecord::Observer
  def after_save(group_membership)
    if group_membership.role_changed?

      user = group_membership.user
      group = group_membership.group

      # Subscribe new committee members to committee threads, if appropriate
      if group_membership.role == "committee"
        user.prefs.update(involve_my_groups_admin: true)
        if user.prefs.involve_my_groups == "subscribe"
          group.threads.where(privacy: "committee").find_each do |thread|
            thread.add_subscriber(user)
          end
        end
      end

      # Remove ex-committee members from committee threads
      if group_membership.role == "member" && group_membership.role_was == "committee"
        group.threads.where(privacy: "committee").find_each do |thread|
          subscription = user.thread_subscriptions.to(thread)
          subscription&.destroy
        end
      end
    end
  end

  def after_create(group_membership)
    user = group_membership.user
    group = group_membership.group
    if user.prefs.involve_my_groups == "subscribe"
      group.threads.each do |thread|
        if permissions_check(user, thread) && thread.has_issue? && !user.ever_subscribed_to_thread?(thread)
          thread.add_subscriber(user)
        end
      end
    end

    if user.prefs.involve_my_groups_admin == true
      group.threads.each do |thread|
        if permissions_check(user, thread) && !thread.has_issue? && !user.ever_subscribed_to_thread?(thread)
          thread.add_subscriber(user)
        end
      end
    end
  end

  def after_destroy(group_membership)
    user = group_membership.user
    group = group_membership.group
    user.subscribed_threads.where(group_id: group.id, privacy: %w[committee group]).find_each do |thread|
      subscription = user.thread_subscriptions.to(thread)
      subscription&.destroy
    end
  end

  private

  def permissions_check(user, thread)
    Authorization::Engine.instance.permit? :show, object: thread, user: user, user_roles: %i[member guest]
  end
end
