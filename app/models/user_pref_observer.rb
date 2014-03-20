class UserPrefObserver < ActiveRecord::Observer
  def after_save(pref)
    if pref.involve_my_groups_admin_changed?
      if pref.involve_my_groups_admin
        user = pref.user
        user.groups.each do |group|
          group.threads.without_issue.each do |thread|
            if permissions_check(user, thread) && !user.ever_subscribed_to_thread?(thread)
              thread.add_subscriber(user)
            end
          end
        end
      end
    end
  end

  def permissions_check(user, thread)
    Authorization::Engine.instance.permit? :show, object: thread, user: user, user_roles: [:member, :guest]
  end
end
