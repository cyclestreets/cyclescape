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

    # Retrieve user and category IDs from user locations that intersect with the issue
    # and where the user has the notification preference on
    locations = UserLocation.intersects(buffered_location).select(["user_locations.user_id AS user_id", :category_id]).
        joins(:user => :prefs).
        where(user_prefs: {notify_new_user_locations_issue: true})

    locations.each do |loc|
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
