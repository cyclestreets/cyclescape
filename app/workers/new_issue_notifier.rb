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
    process_for_user_locations(issue)
  end

  def self.process_for_user_locations(issue)
    # Expand radius of issue location
    buffered_location = issue.location.buffer(Geo::USER_LOCATIONS_BUFFER)

    # Retrieve user locations that intersect with the issue
    # and where the user has the notification preference on
    locations = UserLocation.intersects(buffered_location).
        joins(:user => :prefs).
        where(user_prefs: {notify_new_user_locations_issue: true})

    # Filter the returned locations to ensure only one location is returned per user,
    # and that it is the smallest (i.e. most relevant) location. Refactoring this into
    # the Arel query above is left as an exercise for the reader.
    l2 = []
    locations.each do |loc|
      a = l2.detect{|l| l.user_id == loc.user_id }
      if a == nil
        l2 << loc
      elsif a.location.buffer(0.0001).area > loc.location.buffer(0.0001).area # buffer slightly, to turn points into polygons
        l2.delete(a)
        l2 << loc
      end
    end

    l2.each do |loc|
      # Symbol keys are converted to strings by Resque
      opts = {"user_id" => loc.user_id, "category_id" => loc.category_id, "issue_id" => issue.id}
      Resque.enqueue(NewIssueNotifier, :notify_new_user_location_issue, opts)
    end
  end

  def self.notify_new_user_location_issue(opts)
    user = User.find(opts["user_id"])
    issue = Issue.find(opts["issue_id"])
    category = LocationCategory.find(opts["category_id"])
    Notifications.new_user_location_issue(user, issue, category).deliver
  end
end
