class NewThreadNotifier
  def self.queue
    :outbound_mail
  end

  def self.perform(method, *args)
    send(method, *args)
  end

  def self.notify_new_thread(thread)
    Resque.enqueue(NewThreadNotifier, :queue_new_thread, thread.id)
  end

  def self.queue_new_thread(thread_id)
    thread = MessageThread.find(thread_id)
    Resque.enqueue(NewThreadNotifier, :notify_new_group_thread, thread.id) if thread.group
    Resque.enqueue(NewThreadNotifier, :notify_new_user_location_issue_thread, thread.id) if thread.issue
  end

  def self.notify_new_group_thread(thread_id)
    thread = MessageThread.find(thread_id)
    members = thread.group.members.active.with_pref(:notify_new_group_thread)
    members.each do |member|
      Resque.enqueue(NewThreadNotifier, :send_new_group_thread_notification, thread.id, member.id)
    end
  end

  def self.send_new_group_thread_notification(thread_id, user_id)
    thread = MessageThread.find(thread_id)
    user = User.find(user_id)
    Notifications.new_group_thread(thread, user).deliver
  end

  def self.notify_new_user_location_issue_thread(thread_id)
    thread = MessageThread.find(thread_id)
    buffered_location = thread.issue.location.buffer(Geo::USER_LOCATIONS_BUFFER)

    # Retrieve user locations that intersect with the issue
    # and where the user has the notification preference on
    locations = UserLocation.intersects(buffered_location).
        joins(:user => :prefs).
        where(user_prefs: {notify_new_user_locations_issue_thread: true}).
        all

    # Filter the returned locations to ensure only one location is returned per user,
    # and that it is the smallest (i.e. most relevant) location. Refactoring this into
    # the Arel query above is left as an exercise for the reader.
    filtered = locations.group_by(&:user_id).map do |user_id, locs|
      locs.sort_by {|loc| loc.location.buffer(0.0001).area }.first
    end

    filtered.each do |loc|
      # Only send notifications to people who have permission to read the thread
      next unless Authorization::Engine.instance.permit? :show, { object: thread, user: loc.user }

      # Don't send notifications to people who are already auto-subscribed to the thread!!!!

      # Symbol keys are converted to strings by Resque
      opts = { "thread_id" => thread.id, "user_location_id" => loc.id}
      Resque.enqueue(NewThreadNotifier, :send_new_user_location_thread_notification, opts)
    end
  end

  def self.send_new_user_location_thread_notification(opts)
    thread = MessageThread.find(opts["thread_id"])
    user_location = UserLocation.find(opts["user_location_id"])
    Notifications.new_user_location_issue_thread(thread, user_location).deliver
  end
end
