class ThreadList
  def self.recent_from_groups(groups, limit)
    MessageThread.where(group_id: groups).order_by_latest_message.limit(limit)
  end

  def self.recent_involved_with(user, limit)
    user.involved_threads.order_by_latest_message.limit(limit)
  end
end
