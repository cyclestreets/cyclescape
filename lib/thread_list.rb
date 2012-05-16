class ThreadList
  def self.recent_from_groups(groups, limit)
    MessageThread.where(group_id: groups).order_by_latest_message.limit(limit)
  end

  def self.recent_public_from_groups(groups, limit)
    MessageThread.public.where(group_id: groups).order_by_latest_message.limit(limit)
  end

  def self.issue_threads_from_group(group)
    group.threads.order_by_latest_message.with_issue
  end

  def self.general_threads_from_group(group)
    group.threads.order_by_latest_message.without_issue
  end

  def self.recent_involved_with(user, limit)
    user.involved_threads.order_by_latest_message.limit(limit)
  end

  def self.public_recent_involved_with(user, limit)
    recent_involved_with(user, limit).public
  end

  def self.recent_public
    MessageThread.public.order_by_latest_message
  end

  def self.with_upcoming_deadlines(user, limit)
    user.subscribed_threads.with_upcoming_deadlines.limit(limit)
  end
end
