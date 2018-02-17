# frozen_string_literal: true

class NewThreadNotifier
  def self.queue
    :mailers
  end

  def self.perform(method, *args)
    send(method, *args)
  end

  def self.notify_new_thread(thread)
    Resque.enqueue(NewThreadNotifier, :queue_new_thread, thread.id)
  end

  def self.queue_new_thread(thread_id)
    thread = MessageThread.find(thread_id)

    l1 = thread.group ? list_for_new_group_thread(thread) : {}
    l2 = thread.issue ? list_for_new_user_location_issue_thread(thread) : {}
    # merge the two lists, which are keyed on user id. This ensure each user only receives one notification.
    l1.merge(l2).each_value do |v|
      Resque.enqueue(NewThreadNotifier, v[:type], v[:opts])
    end
  end

  def self.list_for_new_group_thread(thread)
    # Figure out the correct preference combination, depending on whether the thread has an issue or
    # is just an "administrative" thread.
    t = UserPref.arel_table
    pref = t[:involve_my_groups].in(%w(notify subscribe))
    constraint = thread.issue ? pref : pref.and(t[:involve_my_groups_admin].eq(true))

    if thread.private_to_committee?
      members = thread.group.committee_members.active.joins(:prefs).where(constraint)
    else
      members = thread.group.members.active.joins(:prefs).where(constraint)
    end

    list = {}
    members.each do |member|
      # Don't send a notification if they are already (auto) subscribed to the thread
      next if member.subscribed_to_thread?(thread)

      opts = { 'thread_id' => thread.id, 'member_id' => member.id }
      list[member.id] = { type: :send_new_group_thread_notification, opts: opts }
    end

    list
  end

  def self.send_new_group_thread_notification(opts)
    thread = MessageThread.find(opts['thread_id'])
    user = User.find(opts['member_id'])
    Notifications.new_group_thread(thread, user).deliver_now if user.prefs.enable_email?
  end

  def self.list_for_new_user_location_issue_thread(thread)
    buffered_location = thread.issue.location.buffer(Geo::USER_LOCATIONS_BUFFER)

    # Retrieve user locations that intersect with the issue
    # and where the user has the notification preference on
    locations = UserLocation.intersects(buffered_location).
        joins(user: :prefs).
        where(UserPref.arel_table[:involve_my_locations].in(%w(notify subscribe)))

    # Filter the returned locations to ensure only one location is returned per user,
    # and that it is the smallest (i.e. most relevant) location. Refactoring this into
    # the Arel query above is left as an exercise for the reader.
    filtered = locations.group_by(&:user_id).map do |user_id, locs|
      locs.sort_by { |loc| loc.location.buffer(0.0001).area }.first
    end

    list = {}
    filtered.each do |loc|
      # Don't send a notification if they are already (auto) subscribed to the thread
      next if loc.user.subscribed_to_thread?(thread)

      # Only send notifications to people who have permission to read the thread
      next unless Authorization::Engine.instance.permit? :show, object: thread, user: loc.user

      # Symbol keys are converted to strings by Resque
      opts = { 'thread_id' => thread.id, 'user_location_id' => loc.id }
      list[loc.user.id] = { type: :send_new_user_location_thread_notification, opts: opts }
    end

    list
  end

  def self.send_new_user_location_thread_notification(opts)
    thread = MessageThread.find(opts['thread_id'])
    user_location = UserLocation.find(opts['user_location_id'])
    Notifications.new_user_location_issue_thread(thread, user_location).deliver_now if user_location.user.prefs.enable_email?
  end
end
