class ThreadSubscriber
  # This would normally be a resque worker, but it can't be due to race conditions
  # For example, you need to process all the automatic subscriptions before sending
  # the notifications

  # Main entry point
  def self.subscribe_users(thread)
    subscribe_group_users(thread) if thread.group
    subscribe_issue_users(thread) if thread.issue
  end

  def self.subscribe_group_users(thread)
    # If it's an "administrative" discussion, don't subscribe without extra pref
    t = UserPref.arel_table
    pref = t[:involve_my_groups].eq('subscribe')
    constraint = thread.issue ? pref : pref.and(t[:involve_my_groups_admin].eq(true))
    members = thread.group.members.active.joins(:prefs).where(constraint)
    members.each do |member|
      if Authorization::Engine.instance.permit? :show,  object: thread, user: member, user_roles: [:member, :guest]
        thread.subscriptions.create( user: member ) unless member.subscribed_to_thread?(thread)
      end
    end
  end

  def self.subscribe_issue_users(thread)
    buffered_location = thread.issue.location.buffer(Geo::USER_LOCATIONS_BUFFER)

    locations = UserLocation.intersects(buffered_location).
        joins(user: :prefs).
        where(user_prefs: { involve_my_locations: 'subscribe' }).
        all

    locations.each do |loc|
      if Authorization::Engine.instance.permit? :show,  object: thread, user: loc.user, user_roles: [:member, :guest]
        thread.subscriptions.create( user: loc.user ) unless loc.user.subscribed_to_thread?(thread)
      end
    end
  end
end
