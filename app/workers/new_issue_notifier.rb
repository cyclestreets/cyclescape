class NewIssueNotifier
  def self.queue
    :outbound_mail
  end

  def self.perform(method, *args)
    send(method, *args)
  end

  # Entry point, register a new issue to be processed
  def self.new_issue(issue)
    Resque.enqueue(NewIssueNotifier, :process_new_issue, issue.id)
  end

  def self.process_new_issue(id)
    issue = Issue.find(id)

    l1 = list_for_group_locations(issue)
    l2 = list_for_user_locations(issue)
    # merge the two lists, which are keyed on user id. This ensure each user only receives one notification.
    l1.merge(l2).each_value do |v|
      Resque.enqueue(NewIssueNotifier, v[:type], v[:opts])
    end
  end

  def self.list_for_user_locations(issue)
    # Expand radius of issue location
    buffered_location = issue.location.buffer(Geo::USER_LOCATIONS_BUFFER)

    # Retrieve user locations that intersect with the issue
    # and where the user has user locations involvement preference on
    locations = UserLocation.intersects(buffered_location).
        joins(user: :prefs).
        where(UserPref.arel_table[:involve_my_locations].in(%w(notify subscribe)))

    # Filter the returned locations to ensure only one location is returned per user,
    # and that it is the smallest (i.e. most relevant) location. Refactoring this into
    # the Arel query above is left as an exercise for the reader.
    filtered = locations.group_by(&:user_id).map do |user_id, locs|
      locs.sort_by { |loc| loc.location.buffer(0.0001).area }.first
    end

    # Create a hash keyed on user_id, containing the type of notification (actually the method name)
    # and the options for each message
    list = {}
    filtered.each do |loc|
      # Symbol keys are converted to strings by Resque
      opts = { 'user_id' => loc.user_id, 'category_id' => loc.category_id, 'issue_id' => issue.id }
      list[loc.user_id] = { type: :notify_new_user_location_issue, opts: opts }
    end

    list
  end

  def self.notify_new_user_location_issue(opts)
    user = User.find(opts['user_id'])
    issue = Issue.find(opts['issue_id'])
    category = LocationCategory.find(opts['category_id'])
    Notifications.new_user_location_issue(user, issue, category).deliver_later if user.prefs.enable_email
  end

  def self.list_for_group_locations(issue)
    group_profiles = GroupProfile.intersects(issue.location)

    # Create a hash keyed on the user id, containing the type of notification (actually the method name)
    # and the options for each message
    list = {}
    group_profiles.each do |profile|
      users = profile.group.members.joins(:prefs).
          where(UserPref.arel_table[:involve_my_groups].in(%w(notify subscribe)))
      users.each do |user|
        opts = { 'user_id' => user.id, 'group_id' => profile.group.id, 'issue_id' => issue.id }
        list[user.id] = { type: :notify_new_group_location_issue, opts: opts }
      end
    end

    list
  end

  def self.notify_new_group_location_issue(opts)
    user = User.find(opts['user_id'])
    group = Group.find(opts['group_id'])
    issue = Issue.find(opts['issue_id'])
    Notifications.new_group_location_issue(user, group, issue).deliver_later if user.prefs.enable_email
  end
end
