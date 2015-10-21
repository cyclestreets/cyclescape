class UserPrefObserver < ActiveRecord::Observer
  def after_save(pref)
    if pref.involve_my_groups_admin_changed?
      user = pref.user
      if pref.involve_my_groups_admin
        user.groups.each do |group|
          group.threads.without_issue.each do |thread|
            if permissions_check(user, thread) && !user.ever_subscribed_to_thread?(thread)
              thread.add_subscriber(user)
            end
          end
        end
      else
        user.groups.each do |group|
          group.threads.without_issue.each do |thread|
            user.thread_subscriptions.to(thread).destroy if user.subscribed_to_thread?(thread)
          end
        end
      end
    end

    if pref.involve_my_groups_changed?
      user = pref.user
      if pref.involve_my_groups == 'subscribe'
        user.groups.each do |group|
          group.threads.with_issue.each do |thread|
            if permissions_check(user, thread) && !user.ever_subscribed_to_thread?(thread)
              thread.add_subscriber(user)
            end
          end
        end
      end

      if pref.involve_my_groups_was == 'subscribe'
        user.groups.each do |group|
          group.threads.with_issue.each do |thread|
            if user.subscribed_to_thread?(thread)
              unless user.prefs.involve_my_locations == 'subscribe' &&
                     user.buffered_locations &&
                     thread.issue.location.intersects?(user.buffered_locations)
                user.thread_subscriptions.to(thread).destroy
              end
            end
          end
        end
      end
    end

    if pref.involve_my_locations_changed?
      user = pref.user
      if pref.involve_my_locations == 'subscribe'
        user.issues_near_locations.includes(:threads).each do |issue|
          issue.threads.each do |thread|
            if permissions_check(user, thread) && !user.ever_subscribed_to_thread?(thread)
              thread.add_subscriber(user)
            end
          end
        end
      end

      if pref.involve_my_locations_was == 'subscribe'
        user.thread_subscriptions.includes(thread: :group).each do |thread_sub|
          thread = thread_sub.thread
          unless thread.group && thread.group.members.include?(user) && user.prefs.involve_my_groups == 'subscribe'
            thread_sub.destroy
          end
        end
      end
    end
  end

  def permissions_check(user, thread)
    Authorization::Engine.instance.permit? :show, object: thread, user: user, user_roles: [:member, :guest]
  end
end
